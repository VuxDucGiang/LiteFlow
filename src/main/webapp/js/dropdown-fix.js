/**
 * Dropdown Fix for LiteFlow Navigation
 * Fixes dropdown menu functionality after CSS updates
 */

document.addEventListener('DOMContentLoaded', function() {
    console.log('🔧 Initializing dropdown fix...');
    
    // Fix dropdown functionality
    initDropdowns();
    
    // Handle navigation hover behavior
    handleNavigationHover();
    
    // Add missing procurement menu if not exists
    addProcurementMenu();
});

function initDropdowns() {
    // Get all dropdown toggles
    const dropdownToggles = document.querySelectorAll('.dropdown-toggle');
    
    dropdownToggles.forEach(toggle => {
        // Remove existing event listeners
        const newToggle = toggle.cloneNode(true);
        toggle.parentNode.replaceChild(newToggle, toggle);
        
        // Add click event listener
        newToggle.addEventListener('click', function(e) {
            e.preventDefault();
            e.stopPropagation();
            
            const dropdown = this.closest('.nav-item.dropdown');
            const menu = dropdown.querySelector('.dropdown-menu');
            
            // Close all other dropdowns
            closeAllDropdowns();
            
            // Toggle current dropdown
            if (menu) {
                if (dropdown.classList.contains('show')) {
                    dropdown.classList.remove('show');
                    menu.style.display = 'none';
                } else {
                    dropdown.classList.add('show');
                    menu.style.display = 'block';
                }
            }
        });
    });
    
    // Add hover event listeners with auto-hide functionality
    const dropdowns = document.querySelectorAll('.nav-item.dropdown');
    dropdowns.forEach(dropdown => {
        let hoverTimeout;
        let isManuallyOpened = false;
        
        dropdown.addEventListener('mouseenter', function() {
            clearTimeout(hoverTimeout);
            // Close all other dropdowns first
            closeAllDropdowns();
            
            const menu = this.querySelector('.dropdown-menu');
            if (menu) {
                menu.style.display = 'block';
                this.classList.add('show');
            }
        });
        
        dropdown.addEventListener('mouseleave', function() {
            // Only auto-hide if not manually opened
            if (!isManuallyOpened) {
                hoverTimeout = setTimeout(() => {
                    const menu = this.querySelector('.dropdown-menu');
                    if (menu) {
                        menu.style.display = 'none';
                        this.classList.remove('show');
                    }
                }, 100); // Quick hide when mouse leaves
            }
        });
        
        // Track manual open/close via click
        const toggle = dropdown.querySelector('.dropdown-toggle');
        if (toggle) {
            toggle.addEventListener('click', function() {
                isManuallyOpened = !isManuallyOpened;
                if (!isManuallyOpened) {
                    // If manually closed, also close on mouse leave
                    dropdown.addEventListener('mouseleave', function() {
                        hoverTimeout = setTimeout(() => {
                            const menu = this.querySelector('.dropdown-menu');
                            if (menu) {
                                menu.style.display = 'none';
                                this.classList.remove('show');
                            }
                        }, 100);
                    });
                }
            });
        }
    });
    
    // Close dropdowns when clicking outside
    document.addEventListener('click', function(e) {
        if (!e.target.closest('.nav-item.dropdown')) {
            closeAllDropdowns();
        }
    });
    
    // Close dropdowns on escape key
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            closeAllDropdowns();
        }
    });
    
    console.log('✅ Dropdown functionality initialized with hover fix');
}

function closeAllDropdowns() {
    const openDropdowns = document.querySelectorAll('.nav-item.dropdown.show');
    openDropdowns.forEach(dropdown => {
        dropdown.classList.remove('show');
        const menu = dropdown.querySelector('.dropdown-menu');
        if (menu) {
            menu.style.display = 'none';
            menu.style.opacity = '0';
            menu.style.visibility = 'hidden';
        }
    });
}

// Global function to handle navigation hover
function handleNavigationHover() {
    const navItems = document.querySelectorAll('.nav-item');
    
    navItems.forEach(item => {
        item.addEventListener('mouseenter', function() {
            // Close all dropdowns when entering any nav item
            closeAllDropdowns();
        });
    });
}

function addProcurementMenu() {
    // Check if procurement menu already exists
    const existingProcurement = document.querySelector('.nav-item.dropdown:has(.nav-link:contains("Mua sắm"))');
    if (existingProcurement) {
        console.log('✅ Procurement menu already exists');
        return;
    }
    
    // Find the employee dropdown to add procurement menu after it
    const employeeDropdown = document.querySelector('.nav-item.dropdown:has(.nav-link:contains("Nhân viên"))');
    if (!employeeDropdown) {
        console.log('❌ Employee dropdown not found');
        return;
    }
    
    // Create procurement dropdown menu
    const procurementDropdown = document.createElement('div');
    procurementDropdown.className = 'nav-item dropdown';
    procurementDropdown.innerHTML = `
        <a href="#" class="nav-link dropdown-toggle">
            <i class='bx bx-shopping-bag'></i> Mua sắm
            <i class='bx bx-chevron-down' style="margin-left: 4px; font-size: 14px;"></i>
        </a>
        <div class="dropdown-menu">
            <a href="${window.location.origin}${window.location.pathname.includes('/LiteFlow') ? '/LiteFlow' : ''}/procurement/dashboard" class="dropdown-item">
                <i class='bx bxs-dashboard'></i> Tổng quan
            </a>
            <a href="${window.location.origin}${window.location.pathname.includes('/LiteFlow') ? '/LiteFlow' : ''}/procurement/supplier" class="dropdown-item">
                <i class='bx bx-store'></i> Nhà cung cấp
            </a>
            <a href="${window.location.origin}${window.location.pathname.includes('/LiteFlow') ? '/LiteFlow' : ''}/procurement/po" class="dropdown-item">
                <i class='bx bx-receipt'></i> Đơn đặt hàng
            </a>
            <a href="${window.location.origin}${window.location.pathname.includes('/LiteFlow') ? '/LiteFlow' : ''}/procurement/gr" class="dropdown-item">
                <i class='bx bx-package'></i> Nhận hàng
            </a>
            <a href="${window.location.origin}${window.location.pathname.includes('/LiteFlow') ? '/LiteFlow' : ''}/procurement/invoice" class="dropdown-item">
                <i class='bx bx-file'></i> Hóa đơn
            </a>
        </div>
    `;
    
    // Insert after employee dropdown
    employeeDropdown.parentNode.insertBefore(procurementDropdown, employeeDropdown.nextSibling);
    
    // Initialize the new dropdown
    const newToggle = procurementDropdown.querySelector('.dropdown-toggle');
    newToggle.addEventListener('click', function(e) {
        e.preventDefault();
        e.stopPropagation();
        
        const dropdown = this.closest('.nav-item.dropdown');
        const menu = dropdown.querySelector('.dropdown-menu');
        
        // Close all other dropdowns
        closeAllDropdowns();
        
        // Toggle current dropdown
        if (menu) {
            if (dropdown.classList.contains('show')) {
                dropdown.classList.remove('show');
                menu.style.display = 'none';
            } else {
                dropdown.classList.add('show');
                menu.style.display = 'block';
            }
        }
    });
    
    console.log('✅ Procurement menu added successfully');
}

// Force dropdown visibility with important styles
function forceDropdownVisibility() {
    const style = document.createElement('style');
    style.textContent = `
        .nav-item.dropdown .dropdown-menu {
            display: none !important;
            position: absolute !important;
            top: 100% !important;
            left: 0 !important;
            background: #ffffff !important;
            border: 1px solid #e5e7eb !important;
            border-radius: 8px !important;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.15) !important;
            min-width: 200px !important;
            z-index: 9999 !important;
            padding: 8px 0 !important;
        }
        
        .nav-item.dropdown.show .dropdown-menu {
            display: block !important;
        }
        
        .dropdown-item {
            display: flex !important;
            align-items: center !important;
            gap: 8px !important;
            padding: 12px 16px !important;
            color: #374151 !important;
            text-decoration: none !important;
            border-bottom: 1px solid #f3f4f6 !important;
            transition: all 0.2s ease !important;
        }
        
        .dropdown-item:last-child {
            border-bottom: none !important;
        }
        
        .dropdown-item:hover {
            background: #f9fafb !important;
            color: #0080FF !important;
        }
        
        .dropdown-item i {
            font-size: 16px !important;
            width: 20px !important;
            text-align: center !important;
        }
    `;
    document.head.appendChild(style);
}

// Initialize force visibility
forceDropdownVisibility();

console.log('🔧 Dropdown fix loaded successfully!');
