package com.liteflow.service.inventory;

import com.liteflow.dao.inventory.ProductDAO;
import com.liteflow.model.inventory.Product;
import com.liteflow.model.inventory.ProductDisplayDTO;
import com.liteflow.model.inventory.ProductPriceDTO;
import com.liteflow.dao.BaseDAO;
import jakarta.persistence.EntityManager;
import jakarta.persistence.Query;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class ProductService {
    private final ProductDAO productDAO;

    public ProductService() {
        this.productDAO = new ProductDAO();
    }

    public List<Product> getAllProducts() {
        System.out.println("=== DEBUG: ProductService.getAllProducts() ===");
        try {
            List<Product> products = productDAO.findAll();
            System.out.println("Số lượng sản phẩm từ DAO: " + (products != null ? products.size() : "null"));
            return products;
        } catch (Exception e) {
            System.err.println("❌ Lỗi trong ProductService.getAllProducts(): " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }

    public List<ProductDisplayDTO> getAllProductsWithPriceAndStock() {
        System.out.println("=== DEBUG: ProductService.getAllProductsWithPriceAndStock() ===");
        try {
            EntityManager em = BaseDAO.emf.createEntityManager();
            List<ProductDisplayDTO> result = new ArrayList<>();
            
            try {
                // Query để lấy thông tin sản phẩm với giá, tồn kho và category
                String jpql = """
                    SELECT p.productId, p.name, pv.size, pv.price, 
                           COALESCE(ps.amount, 0) as stockAmount, 
                           p.isDeleted, p.imageUrl, c.name as categoryName
                    FROM Product p 
                    LEFT JOIN ProductVariant pv ON p.productId = pv.product.productId 
                    LEFT JOIN ProductStock ps ON pv.productVariantId = ps.productVariant.productVariantId
                    LEFT JOIN ProductCategory pc ON p.productId = pc.product.productId
                    LEFT JOIN Category c ON pc.category.categoryId = c.categoryId
                    WHERE pv.isDeleted = false OR pv.isDeleted IS NULL
                    ORDER BY p.name, pv.size
                    """;
                
                Query query = em.createQuery(jpql);
                @SuppressWarnings("unchecked")
                List<Object[]> results = query.getResultList();
                
                for (Object[] row : results) {
                    ProductDisplayDTO dto = new ProductDisplayDTO();
                    dto.setProductId((UUID) row[0]);
                    dto.setProductName((String) row[1]);
                    dto.setSize((String) row[2]);
                    // Convert BigDecimal to Double
                    if (row[3] != null) {
                        dto.setPrice(((java.math.BigDecimal) row[3]).doubleValue());
                    } else {
                        dto.setPrice(0.0);
                    }
                    dto.setStockAmount(((Number) row[4]).intValue());
                    dto.setIsDeleted((Boolean) row[5]);
                    dto.setImageUrl((String) row[6]);
                    dto.setCategoryName((String) row[7]);
                    
                    // Tạo mã sản phẩm từ ID
                    dto.setProductCode("SP" + String.format("%06d", Math.abs(dto.getProductId().hashCode()) % 1000000));
                    
                    result.add(dto);
                }
                
                System.out.println("Số lượng sản phẩm với giá và tồn kho: " + result.size());
                return result;
                
            } finally {
                em.close();
            }
        } catch (Exception e) {
            System.err.println("❌ Lỗi trong ProductService.getAllProductsWithPriceAndStock(): " + e.getMessage());
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    public Product getById(UUID id) {
        return productDAO.findById(id);
    }

    public boolean addProduct(Product p) {
        return productDAO.insert(p);
    }

    public boolean updateProduct(Product p) {
        return productDAO.update(p);
    }

    public boolean deleteProduct(UUID id) {
        return productDAO.delete(id);
    }
    
    public List<ProductPriceDTO> getAllProductsWithPriceInfo() {
        System.out.println("=== DEBUG: ProductService.getAllProductsWithPriceInfo() ===");
        try {
            EntityManager em = BaseDAO.emf.createEntityManager();
            List<ProductPriceDTO> result = new ArrayList<>();
            
            try {
                // Query đơn giản để lấy thông tin sản phẩm với giá
                String jpql = """
                    SELECT p.productId, p.name, pv.size, pv.originalPrice, pv.price, 
                           p.isDeleted
                    FROM Product p 
                    LEFT JOIN ProductVariant pv ON p.productId = pv.product.productId 
                    WHERE (pv.isDeleted = false OR pv.isDeleted IS NULL)
                    AND (p.isDeleted = false OR p.isDeleted IS NULL)
                    ORDER BY p.name, pv.size
                    """;
                
                Query query = em.createQuery(jpql);
                @SuppressWarnings("unchecked")
                List<Object[]> results = query.getResultList();
                
                for (Object[] row : results) {
                    ProductPriceDTO dto = new ProductPriceDTO();
                    dto.setProductId((UUID) row[0]);
                    dto.setProductName((String) row[1]);
                    dto.setSize((String) row[2]);
                    // Convert BigDecimal to Double
                    if (row[3] != null) {
                        dto.setOriginalPrice(((java.math.BigDecimal) row[3]).doubleValue());
                    } else {
                        dto.setOriginalPrice(0.0);
                    }
                    if (row[4] != null) {
                        dto.setSellingPrice(((java.math.BigDecimal) row[4]).doubleValue());
                    } else {
                        dto.setSellingPrice(0.0);
                    }
                    dto.setIsDeleted((Boolean) row[5]);
                    dto.setCategoryName("Chưa phân loại");
                    
                    // Tạo mã sản phẩm từ ID
                    dto.setProductCode("SP" + String.format("%06d", Math.abs(dto.getProductId().hashCode()) % 1000000));
                    
                    result.add(dto);
                }
                
                System.out.println("Số lượng sản phẩm với thông tin giá: " + result.size());
                return result;
                
            } finally {
                em.close();
            }
        } catch (Exception e) {
            System.err.println("❌ Lỗi trong ProductService.getAllProductsWithPriceInfo(): " + e.getMessage());
            e.printStackTrace();
            return new ArrayList<>();
        }
    }
    
    public List<String> getDistinctCategoriesFromProducts() {
        System.out.println("=== DEBUG: ProductService.getDistinctCategoriesFromProducts() ===");
        try {
            EntityManager em = BaseDAO.emf.createEntityManager();
            
            try {
                // Query để lấy các danh mục khác nhau từ bảng Category
                String jpql = """
                    SELECT DISTINCT c.name 
                    FROM Category c 
                    WHERE c.name IS NOT NULL
                    ORDER BY c.name
                    """;
                
                Query query = em.createQuery(jpql);
                @SuppressWarnings("unchecked")
                List<String> result = query.getResultList();
                
                System.out.println("Số lượng danh mục từ sản phẩm: " + result.size());
                if (!result.isEmpty()) {
                    System.out.println("Các danh mục tìm thấy:");
                    for (String category : result) {
                        System.out.println("  - " + category);
                    }
                }
                return result;
                
            } finally {
                em.close();
            }
        } catch (Exception e) {
            System.err.println("❌ Lỗi trong ProductService.getDistinctCategoriesFromProducts(): " + e.getMessage());
            e.printStackTrace();
            return new ArrayList<>();
        }
    }
}
