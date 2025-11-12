/**
 * AI Agent Configuration Page JavaScript
 * Handles loading, displaying, saving, and resetting configurations
 */

class AIAgentConfig {
    constructor() {
        this.currentCategory = 'STOCK_ALERT';
        this.configs = {};
        this.originalConfigs = {};
        this.hasChanges = false;
        this.init();
    }
    
    init() {
        this.setupEventListeners();
        this.loadAllConfigs();
    }
    
    setupEventListeners() {
        // Tab buttons
        document.querySelectorAll('.tab-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                const category = e.currentTarget.getAttribute('data-category');
                this.switchTab(category);
            });
        });
        
        // Save button
        document.getElementById('saveBtn')?.addEventListener('click', () => {
            this.saveConfigs();
        });
        
        // Reset button
        document.getElementById('resetBtn')?.addEventListener('click', () => {
            this.resetCategory();
        });
        
        // Cancel button
        document.getElementById('cancelBtn')?.addEventListener('click', () => {
            this.cancelChanges();
        });
    }
    
    async loadAllConfigs() {
        try {
            this.showLoading();
            
            const response = await fetch(`${this.getContextPath()}/api/ai-agent-config`);
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            
            const data = await response.json();
            if (data.success) {
                this.configs = data;
                this.originalConfigs = JSON.parse(JSON.stringify(data));
                this.renderCurrentCategory();
                this.hideLoading();
                this.showContent();
            } else {
                throw new Error(data.error || 'Failed to load configurations');
            }
        } catch (error) {
            console.error('Error loading configs:', error);
            this.showError('Không thể tải cấu hình: ' + error.message);
            this.hideLoading();
        }
    }
    
    switchTab(category) {
        // Update active tab
        document.querySelectorAll('.tab-btn').forEach(btn => {
            btn.classList.remove('active');
        });
        document.querySelector(`[data-category="${category}"]`)?.classList.add('active');
        
        this.currentCategory = category;
        this.renderCurrentCategory();
    }
    
    renderCurrentCategory() {
        const contentDiv = document.getElementById('configContent');
        if (!contentDiv) return;
        
        const categoryConfigs = this.configs[this.currentCategory];
        if (!categoryConfigs) {
            contentDiv.innerHTML = '<div class="empty-state"><i class="bx bx-info-circle"></i><p>Không có cấu hình nào</p></div>';
            return;
        }
        
        let html = '<div class="config-section">';
        html += `<div class="config-section-title">`;
        html += `<i class='bx ${this.getCategoryIcon(this.currentCategory)}'></i>`;
        html += `${this.getCategoryName(this.currentCategory)}</div>`;
        
        for (const [key, config] of Object.entries(categoryConfigs)) {
            html += this.renderConfigItem(key, config);
        }
        
        html += '</div>';
        contentDiv.innerHTML = html;
        
        // Attach event listeners to inputs
        this.attachInputListeners();
    }
    
    renderConfigItem(key, config) {
        const isDefault = config.isDefaultValue;
        const value = config.configValue;
        const type = config.configType;
        
        let inputHtml = '';
        
        if (type === 'BOOLEAN') {
            inputHtml = `
                <label class="toggle-switch">
                    <input type="checkbox" data-key="${key}" ${value === 'true' ? 'checked' : ''}>
                    <span class="toggle-slider"></span>
                </label>
            `;
        } else if (type === 'TIME') {
            inputHtml = `<input type="time" class="config-input time" data-key="${key}" value="${value}">`;
        } else if (type === 'INTEGER' || type === 'DECIMAL') {
            const inputType = type === 'DECIMAL' ? 'number' : 'number';
            const step = type === 'DECIMAL' ? '0.1' : '1';
            inputHtml = `
                <input type="${inputType}" 
                       class="config-input number" 
                       data-key="${key}" 
                       value="${value}"
                       step="${step}"
                       min="${config.minValue || ''}"
                       max="${config.maxValue || ''}">
            `;
        } else {
            inputHtml = `<input type="text" class="config-input string" data-key="${key}" value="${this.escapeHtml(value)}">`;
        }
        
        return `
            <div class="config-item" data-key="${key}">
                <div class="config-item-header">
                    <div class="config-item-label">
                        <span class="label">${this.escapeHtml(config.displayName)}</span>
                        ${config.description ? `<span class="description">${this.escapeHtml(config.description)}</span>` : ''}
                    </div>
                    <div class="config-item-value">
                        ${isDefault ? '<span class="default-badge is-default">Mặc định</span>' : '<span class="default-badge">Đã thay đổi</span>'}
                    </div>
                </div>
                <div class="config-input-wrapper">
                    ${inputHtml}
                    <div class="validation-error"></div>
                </div>
            </div>
        `;
    }
    
    attachInputListeners() {
        document.querySelectorAll('.config-input, .toggle-switch input').forEach(input => {
            input.addEventListener('change', (e) => {
                const key = e.target.getAttribute('data-key');
                let value = e.target.value;
                
                if (e.target.type === 'checkbox') {
                    value = e.target.checked ? 'true' : 'false';
                }
                
                this.updateConfigValue(key, value);
                this.validateInput(e.target);
            });
            
            input.addEventListener('input', (e) => {
                this.validateInput(e.target);
            });
        });
    }
    
    updateConfigValue(key, value) {
        const category = this.currentCategory;
        if (this.configs[category] && this.configs[category][key]) {
            this.configs[category][key].configValue = value;
            this.configs[category][key].isDefaultValue = 
                value === this.configs[category][key].defaultValue;
            this.hasChanges = true;
            this.updateDefaultBadge(key);
        }
    }
    
    updateDefaultBadge(key) {
        const item = document.querySelector(`[data-key="${key}"]`);
        if (!item) return;
        
        const badge = item.querySelector('.default-badge');
        const config = this.configs[this.currentCategory][key];
        
        if (badge && config) {
            if (config.isDefaultValue) {
                badge.textContent = 'Mặc định';
                badge.classList.add('is-default');
            } else {
                badge.textContent = 'Đã thay đổi';
                badge.classList.remove('is-default');
            }
        }
    }
    
    validateInput(input) {
        const key = input.getAttribute('data-key');
        const value = input.value;
        const config = this.configs[this.currentCategory][key];
        if (!config) return;
        
        const item = input.closest('.config-item');
        const errorDiv = item.querySelector('.validation-error');
        
        // Remove previous validation
        item.classList.remove('has-error');
        errorDiv.textContent = '';
        
        // Validate based on type
        let isValid = true;
        let errorMessage = '';
        
        if (config.configType === 'INTEGER') {
            const intValue = parseInt(value);
            if (isNaN(intValue)) {
                isValid = false;
                errorMessage = 'Giá trị phải là số nguyên';
            } else {
                if (config.minValue && intValue < parseInt(config.minValue)) {
                    isValid = false;
                    errorMessage = `Giá trị tối thiểu: ${config.minValue}`;
                }
                if (config.maxValue && intValue > parseInt(config.maxValue)) {
                    isValid = false;
                    errorMessage = `Giá trị tối đa: ${config.maxValue}`;
                }
            }
        } else if (config.configType === 'DECIMAL') {
            const decimalValue = parseFloat(value);
            if (isNaN(decimalValue)) {
                isValid = false;
                errorMessage = 'Giá trị phải là số';
            } else {
                if (config.minValue && decimalValue < parseFloat(config.minValue)) {
                    isValid = false;
                    errorMessage = `Giá trị tối thiểu: ${config.minValue}`;
                }
                if (config.maxValue && decimalValue > parseFloat(config.maxValue)) {
                    isValid = false;
                    errorMessage = `Giá trị tối đa: ${config.maxValue}`;
                }
            }
        } else if (config.configType === 'TIME') {
            if (!value.match(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/)) {
                isValid = false;
                errorMessage = 'Định dạng thời gian không hợp lệ (HH:mm)';
            }
        }
        
        if (!isValid) {
            item.classList.add('has-error');
            errorDiv.textContent = errorMessage;
        }
        
        return isValid;
    }
    
    async saveConfigs() {
        const category = this.currentCategory;
        const categoryConfigs = this.configs[category];
        if (!categoryConfigs) return;
        
        // Validate all inputs
        let allValid = true;
        document.querySelectorAll(`.config-item[data-key]`).forEach(item => {
            const input = item.querySelector('.config-input, .toggle-switch input');
            if (input && !this.validateInput(input)) {
                allValid = false;
            }
        });
        
        if (!allValid) {
            this.showError('Vui lòng sửa các lỗi trước khi lưu');
            return;
        }
        
        // Collect changes
        const updates = {};
        for (const [key, config] of Object.entries(categoryConfigs)) {
            const original = this.originalConfigs[category]?.[key];
            if (original && config.configValue !== original.configValue) {
                updates[key] = config.configValue;
            }
        }
        
        if (Object.keys(updates).length === 0) {
            this.showSuccess('Không có thay đổi nào để lưu');
            return;
        }
        
        try {
            this.showLoading();
            
            const response = await fetch(`${this.getContextPath()}/api/ai-agent-config`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    configs: updates
                })
            });
            
            if (!response.ok) {
                const errorData = await response.json();
                throw new Error(errorData.error || 'Failed to save configurations');
            }
            
            const result = await response.json();
            if (result.success) {
                // Update original configs
                for (const key in updates) {
                    if (this.originalConfigs[category] && this.originalConfigs[category][key]) {
                        this.originalConfigs[category][key].configValue = updates[key];
                        this.originalConfigs[category][key].isDefaultValue = 
                            updates[key] === this.originalConfigs[category][key].defaultValue;
                    }
                }
                
                this.hasChanges = false;
                this.showSuccess('Đã lưu cấu hình thành công!');
                this.renderCurrentCategory(); // Refresh to update badges
            } else {
                throw new Error(result.error || 'Failed to save');
            }
        } catch (error) {
            console.error('Error saving configs:', error);
            this.showError('Không thể lưu cấu hình: ' + error.message);
        } finally {
            this.hideLoading();
        }
    }
    
    async resetCategory() {
        if (!confirm('Bạn có chắc muốn khôi phục tất cả cấu hình trong mục này về giá trị mặc định?')) {
            return;
        }
        
        try {
            this.showLoading();
            
            const response = await fetch(`${this.getContextPath()}/api/ai-agent-config`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    action: 'reset',
                    category: this.currentCategory
                })
            });
            
            if (!response.ok) {
                const errorData = await response.json();
                throw new Error(errorData.error || 'Failed to reset configurations');
            }
            
            const result = await response.json();
            if (result.success) {
                // Reload configs
                await this.loadAllConfigs();
                this.showSuccess('Đã khôi phục về giá trị mặc định!');
            } else {
                throw new Error(result.error || 'Failed to reset');
            }
        } catch (error) {
            console.error('Error resetting configs:', error);
            this.showError('Không thể khôi phục: ' + error.message);
        } finally {
            this.hideLoading();
        }
    }
    
    cancelChanges() {
        if (this.hasChanges && !confirm('Bạn có chắc muốn hủy các thay đổi chưa lưu?')) {
            return;
        }
        
        // Restore from original
        this.configs = JSON.parse(JSON.stringify(this.originalConfigs));
        this.hasChanges = false;
        this.renderCurrentCategory();
        this.showSuccess('Đã hủy các thay đổi');
    }
    
    // UI Helper Methods
    showLoading() {
        document.getElementById('loadingIndicator')?.style.setProperty('display', 'block');
        document.getElementById('configContent')?.style.setProperty('display', 'none');
        document.querySelector('.config-actions')?.style.setProperty('display', 'none');
    }
    
    hideLoading() {
        document.getElementById('loadingIndicator')?.style.setProperty('display', 'none');
    }
    
    showContent() {
        document.getElementById('configContent')?.style.setProperty('display', 'block');
        document.querySelector('.config-actions')?.style.setProperty('display', 'flex');
    }
    
    showError(message) {
        const errorDiv = document.getElementById('errorMessage');
        if (errorDiv) {
            errorDiv.innerHTML = `<i class='bx bx-error-circle'></i> ${this.escapeHtml(message)}`;
            errorDiv.style.display = 'flex';
            setTimeout(() => {
                errorDiv.style.display = 'none';
            }, 5000);
        }
    }
    
    showSuccess(message) {
        const successDiv = document.getElementById('successMessage');
        if (successDiv) {
            successDiv.innerHTML = `<i class='bx bx-check-circle'></i> ${this.escapeHtml(message)}`;
            successDiv.style.display = 'flex';
            setTimeout(() => {
                successDiv.style.display = 'none';
            }, 3000);
        }
    }
    
    getCategoryIcon(category) {
        const icons = {
            'STOCK_ALERT': 'bx-package',
            'DEMAND_FORECAST': 'bx-trending-up',
            'PO_AUTO': 'bx-cart',
            'GPT_SERVICE': 'bx-brain',
            'NOTIFICATION': 'bx-bell'
        };
        return icons[category] || 'bx-cog';
    }
    
    getCategoryName(category) {
        const names = {
            'STOCK_ALERT': 'Cảnh báo Tồn kho',
            'DEMAND_FORECAST': 'Dự báo Nhu cầu',
            'PO_AUTO': 'Tự động Đặt hàng',
            'GPT_SERVICE': 'GPT Service',
            'NOTIFICATION': 'Thông báo'
        };
        return names[category] || category;
    }
    
    getContextPath() {
        const meta = document.querySelector('meta[name="contextPath"]');
        return meta ? meta.getAttribute('content') : '';
    }
    
    escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }
}

// Initialize when DOM is ready (only if not in settings page)
// In settings page, initialization is handled by settings.js
document.addEventListener('DOMContentLoaded', () => {
    // Check if we're in the standalone ai-agent-config page
    const isStandalonePage = document.querySelector('.ai-config-container') && 
                              !document.querySelector('.settings-layout');
    
    if (isStandalonePage) {
        new AIAgentConfig();
    }
    // Otherwise, initialization will be handled by settings.js when section becomes active
});

