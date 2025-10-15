/**
 * Room Table Management Enhancements
 * Professional UI/UX with animations and interactions
 */

class RoomTableManager {
    constructor() {
        this.init();
        this.setupEventListeners();
        this.setupAnimations();
        this.setupPerformanceOptimizations();
    }

    init() {
        // Initialize components
        this.setupSearchFunctionality();
        this.setupTableSorting();
        this.setupStatusAnimations();
        this.setupModalEnhancements();
        this.setupRealTimeUpdates();
    }

    setupEventListeners() {
        // Search functionality
        const searchInput = document.getElementById('searchInput');
        if (searchInput) {
            searchInput.addEventListener('input', this.debounce(this.handleSearch.bind(this), 300));
        }

        // Button interactions
        document.querySelectorAll('.btn').forEach(btn => {
            btn.addEventListener('mouseenter', this.handleButtonHover.bind(this));
            btn.addEventListener('mouseleave', this.handleButtonLeave.bind(this));
            btn.addEventListener('click', this.handleButtonClick.bind(this));
        });

        // Table row interactions
        document.querySelectorAll('.table tr').forEach(row => {
            row.addEventListener('mouseenter', this.handleRowHover.bind(this));
            row.addEventListener('mouseleave', this.handleRowLeave.bind(this));
        });

        // Status badges
        document.querySelectorAll('.status').forEach(status => {
            status.addEventListener('mouseenter', this.handleStatusHover.bind(this));
            status.addEventListener('mouseleave', this.handleStatusLeave.bind(this));
        });
    }

    setupAnimations() {
        // Staggered animations for stat cards
        const statCards = document.querySelectorAll('.stat-card');
        statCards.forEach((card, index) => {
            card.style.animationDelay = `${index * 0.1}s`;
            card.classList.add('animate-fade-in-up');
        });

        // Animate table rows on load
        const tableRows = document.querySelectorAll('.table tbody tr');
        tableRows.forEach((row, index) => {
            row.style.animationDelay = `${index * 0.05}s`;
            row.classList.add('animate-fade-in-right');
        });

        // Animate section titles
        const sectionTitles = document.querySelectorAll('.section-title');
        sectionTitles.forEach(title => {
            title.classList.add('animate-fade-in-left');
        });

        // Animate toolbar
        const toolbar = document.querySelector('.toolbar');
        if (toolbar) {
            toolbar.classList.add('animate-fade-in-down');
        }
    }

    setupSearchFunctionality() {
        // Enhanced search with highlighting
        this.searchResults = [];
        this.currentSearchTerm = '';
    }

    handleSearch(event) {
        const searchTerm = event.target.value.toLowerCase();
        this.currentSearchTerm = searchTerm;
        
        if (searchTerm.length < 2) {
            this.clearSearchHighlights();
            return;
        }

        this.highlightSearchResults(searchTerm);
        this.animateSearchResults();
    }

    highlightSearchResults(searchTerm) {
        const tableRows = document.querySelectorAll('.table tbody tr');
        
        tableRows.forEach(row => {
            const text = row.textContent.toLowerCase();
            const isMatch = text.includes(searchTerm);
            
            if (isMatch) {
                row.classList.add('search-highlight');
                row.style.animation = 'pulse 0.6s ease-out';
            } else {
                row.classList.remove('search-highlight');
                row.style.opacity = '0.5';
            }
        });
    }

    clearSearchHighlights() {
        const tableRows = document.querySelectorAll('.table tbody tr');
        tableRows.forEach(row => {
            row.classList.remove('search-highlight');
            row.style.opacity = '1';
            row.style.animation = '';
        });
    }

    animateSearchResults() {
        const highlightedRows = document.querySelectorAll('.search-highlight');
        highlightedRows.forEach((row, index) => {
            row.style.animationDelay = `${index * 0.1}s`;
            row.classList.add('animate-scale-in');
        });
    }

    setupTableSorting() {
        // Enhanced table sorting with animations
        const sortableHeaders = document.querySelectorAll('.sortable');
        sortableHeaders.forEach(header => {
            header.addEventListener('click', this.handleSort.bind(this));
        });
    }

    handleSort(event) {
        const header = event.currentTarget;
        const table = header.closest('table');
        const tbody = table.querySelector('tbody');
        const rows = Array.from(tbody.querySelectorAll('tr'));
        
        // Add sorting animation
        tbody.style.transition = 'all 0.3s ease-out';
        tbody.style.opacity = '0.7';
        
        setTimeout(() => {
            // Sort logic would go here
            this.animateSortedRows(rows);
            tbody.style.opacity = '1';
        }, 150);
    }

    animateSortedRows(rows) {
        rows.forEach((row, index) => {
            row.style.animationDelay = `${index * 0.05}s`;
            row.classList.add('animate-slide-in-up');
        });
    }

    setupStatusAnimations() {
        // Status badge animations
        const statusBadges = document.querySelectorAll('.status');
        statusBadges.forEach(badge => {
            badge.addEventListener('click', this.handleStatusClick.bind(this));
        });
    }

    handleStatusClick(event) {
        const status = event.currentTarget;
        status.style.animation = 'bounce 0.6s ease-out';
        
        setTimeout(() => {
            status.style.animation = '';
        }, 600);
    }

    handleStatusHover(event) {
        const status = event.currentTarget;
        status.style.transform = 'scale(1.1)';
        status.style.boxShadow = '0 4px 15px rgba(0, 0, 0, 0.2)';
    }

    handleStatusLeave(event) {
        const status = event.currentTarget;
        status.style.transform = 'scale(1)';
        status.style.boxShadow = '';
    }

    setupModalEnhancements() {
        // Enhanced modal interactions
        const modals = document.querySelectorAll('.modal');
        modals.forEach(modal => {
            modal.addEventListener('show', this.handleModalShow.bind(this));
            modal.addEventListener('hide', this.handleModalHide.bind(this));
        });
    }

    handleModalShow(event) {
        const modal = event.target;
        modal.style.animation = 'fadeInUp 0.4s ease-out';
        
        // Add backdrop blur
        const backdrop = modal.querySelector('.modal-backdrop');
        if (backdrop) {
            backdrop.style.backdropFilter = 'blur(10px)';
        }
    }

    handleModalHide(event) {
        const modal = event.target;
        modal.style.animation = 'fadeOutDown 0.3s ease-in';
    }

    setupRealTimeUpdates() {
        // Real-time status updates simulation
        this.updateInterval = setInterval(() => {
            this.simulateStatusUpdates();
        }, 30000); // Update every 30 seconds
    }

    simulateStatusUpdates() {
        const statusBadges = document.querySelectorAll('.status');
        statusBadges.forEach(badge => {
            if (Math.random() < 0.1) { // 10% chance to update
                this.animateStatusChange(badge);
            }
        });
    }

    animateStatusChange(badge) {
        badge.style.animation = 'pulse 0.8s ease-out';
        badge.style.transform = 'scale(1.05)';
        
        setTimeout(() => {
            badge.style.animation = '';
            badge.style.transform = '';
        }, 800);
    }

    handleButtonHover(event) {
        const button = event.currentTarget;
        button.style.transform = 'translateY(-2px)';
        button.style.boxShadow = '0 6px 20px rgba(0, 128, 255, 0.3)';
    }

    handleButtonLeave(event) {
        const button = event.currentTarget;
        button.style.transform = 'translateY(0)';
        button.style.boxShadow = '';
    }

    handleButtonClick(event) {
        const button = event.currentTarget;
        button.style.animation = 'scaleIn 0.2s ease-out';
        
        setTimeout(() => {
            button.style.animation = '';
        }, 200);
    }

    handleRowHover(event) {
        const row = event.currentTarget;
        row.style.transform = 'translateX(8px)';
        row.style.boxShadow = '0 4px 12px rgba(0, 128, 255, 0.15)';
    }

    handleRowLeave(event) {
        const row = event.currentTarget;
        row.style.transform = 'translateX(0)';
        row.style.boxShadow = '';
    }

    setupPerformanceOptimizations() {
        // Intersection Observer for lazy loading
        this.setupIntersectionObserver();
        
        // Debounced scroll handler
        window.addEventListener('scroll', this.debounce(this.handleScroll.bind(this), 16));
        
        // Memory management
        this.setupMemoryManagement();
    }

    setupIntersectionObserver() {
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('animate-fade-in-up');
                }
            });
        }, { threshold: 0.1 });

        // Observe all animatable elements
        document.querySelectorAll('.stat-card, .section-title, .room-table-container').forEach(el => {
            observer.observe(el);
        });
    }

    handleScroll() {
        // Scroll-based animations and optimizations
        const scrollY = window.scrollY;
        const toolbar = document.querySelector('.toolbar');
        
        if (toolbar) {
            if (scrollY > 100) {
                toolbar.style.boxShadow = '0 4px 20px rgba(0, 128, 255, 0.15)';
            } else {
                toolbar.style.boxShadow = '';
            }
        }
    }

    setupMemoryManagement() {
        // Clean up event listeners and intervals
        window.addEventListener('beforeunload', () => {
            if (this.updateInterval) {
                clearInterval(this.updateInterval);
            }
        });
    }

    // Utility functions
    debounce(func, wait) {
        let timeout;
        return function executedFunction(...args) {
            const later = () => {
                clearTimeout(timeout);
                func(...args);
            };
            clearTimeout(timeout);
            timeout = setTimeout(later, wait);
        };
    }

    throttle(func, limit) {
        let inThrottle;
        return function() {
            const args = arguments;
            const context = this;
            if (!inThrottle) {
                func.apply(context, args);
                inThrottle = true;
                setTimeout(() => inThrottle = false, limit);
            }
        };
    }

    // Public API methods
    refreshData() {
        // Refresh table data with animation
        const tableBody = document.querySelector('.table tbody');
        if (tableBody) {
            tableBody.style.opacity = '0.5';
            tableBody.style.transform = 'translateY(20px)';
            
            setTimeout(() => {
                // Simulate data refresh
                tableBody.style.opacity = '1';
                tableBody.style.transform = 'translateY(0)';
                tableBody.style.transition = 'all 0.3s ease-out';
            }, 500);
        }
    }

    exportData() {
        // Export functionality with loading animation
        const exportBtn = document.querySelector('[data-action="export"]');
        if (exportBtn) {
            exportBtn.style.animation = 'pulse 1s infinite';
            exportBtn.textContent = 'Đang xuất...';
            
            setTimeout(() => {
                exportBtn.style.animation = '';
                exportBtn.textContent = 'Xuất dữ liệu';
            }, 2000);
        }
    }

    showNotification(message, type = 'success') {
        // Show notification with animation
        const notification = document.createElement('div');
        notification.className = `notification notification-${type}`;
        notification.textContent = message;
        notification.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            padding: 1rem 1.5rem;
            background: ${type === 'success' ? 'linear-gradient(135deg, #7d2ae8, #00c6ff)' : 'linear-gradient(135deg, #ff6b6b, #ee5a52)'};
            color: white;
            border-radius: 8px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
            z-index: 1000;
            animation: slideInRight 0.4s ease-out;
        `;
        
        document.body.appendChild(notification);
        
        setTimeout(() => {
            notification.style.animation = 'slideOutRight 0.3s ease-in';
            setTimeout(() => {
                document.body.removeChild(notification);
            }, 300);
        }, 3000);
    }
}

// Initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    window.roomTableManager = new RoomTableManager();
    
    // Add global keyboard shortcuts
    document.addEventListener('keydown', (e) => {
        if (e.ctrlKey || e.metaKey) {
            switch(e.key) {
                case 'f':
                    e.preventDefault();
                    document.getElementById('searchInput')?.focus();
                    break;
                case 'r':
                    e.preventDefault();
                    window.roomTableManager.refreshData();
                    break;
            }
        }
    });
});

// Export for global access
window.RoomTableManager = RoomTableManager;
