/**
 * LiteFlow ChatBot - Floating AI Assistant
 * Handles chat UI interactions and GPT API communication
 */

class LiteFlowChatBot {
    constructor() {
        this.isOpen = false;
        this.isTyping = false;
        this.messages = [];
        this.apiEndpoint = this.getContextPath() + '/api/chatbot';
        
        this.init();
    }
    
    getContextPath() {
        // Get context path from current URL
        const path = window.location.pathname;
        const contextPath = path.substring(0, path.indexOf('/', 1));
        return contextPath || '';
    }
    
    init() {
        // Create chat UI
        this.createChatUI();
        
        // Bind events
        this.bindEvents();
        
        // Load chat history from localStorage
        this.loadChatHistory();
        
        console.log('🤖 LiteFlow ChatBot initialized');
    }
    
    createChatUI() {
        const contextPath = this.getContextPath();
        const chatHTML = `
            <!-- Floating Chat Button -->
            <button class="chatbot-button" id="chatbot-button" aria-label="Open Chat">
                <img src="${contextPath}/img/trans_logo.png" alt="LiteFlow" class="chatbot-button-icon">
            </button>
            
            <!-- Chat Window -->
            <div class="chatbot-window" id="chatbot-window">
                <!-- Header -->
                <div class="chatbot-header">
                    <div class="chatbot-header-info">
                        <div class="chatbot-avatar">
                            <img src="${contextPath}/img/trans_logo.png" alt="LiteFlow AI">
                        </div>
                        <div class="chatbot-header-text">
                            <h3>LiteFlow AI Assistant</h3>
                            <p>Trợ lý thông minh • Powered by GPT</p>
                        </div>
                    </div>
                    <button class="chatbot-close" id="chatbot-close" aria-label="Close Chat">
                        ✕
                    </button>
                </div>
                
                <!-- Messages -->
                <div class="chatbot-messages" id="chatbot-messages">
                    <div class="chatbot-welcome">
                        <div class="chatbot-welcome-icon">
                            <img src="${contextPath}/img/trans_logo.png" alt="LiteFlow" style="width: 64px; height: 64px; object-fit: contain;">
                        </div>
                        <h4>Chào mừng đến với LiteFlow! 👋</h4>
                        <p style="margin: 8px 0 0 0; color: var(--gray-600, #4b5563);">
                            Tôi là trợ lý AI của bạn. Hỏi tôi bất cứ điều gì về hệ thống quản lý nhà hàng!
                        </p>
                    </div>
                </div>
                
                <!-- Input -->
                <div class="chatbot-input-container">
                    <input 
                        type="text" 
                        class="chatbot-input" 
                        id="chatbot-input" 
                        placeholder="Nhập tin nhắn..."
                        autocomplete="off"
                    />
                    <button class="chatbot-send-btn" id="chatbot-send" aria-label="Send Message">
                        ➤
                    </button>
                </div>
            </div>
        `;
        
        // Append to body
        document.body.insertAdjacentHTML('beforeend', chatHTML);
    }
    
    bindEvents() {
        const button = document.getElementById('chatbot-button');
        const closeBtn = document.getElementById('chatbot-close');
        const sendBtn = document.getElementById('chatbot-send');
        const input = document.getElementById('chatbot-input');
        
        // Toggle chat window
        button.addEventListener('click', () => this.toggleChat());
        closeBtn.addEventListener('click', () => this.closeChat());
        
        // Send message
        sendBtn.addEventListener('click', () => this.sendMessage());
        input.addEventListener('keypress', (e) => {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                this.sendMessage();
            }
        });
    }
    
    toggleChat() {
        this.isOpen = !this.isOpen;
        const window = document.getElementById('chatbot-window');
        const button = document.getElementById('chatbot-button');
        
        if (this.isOpen) {
            window.classList.add('active');
            button.classList.add('active');
            document.getElementById('chatbot-input').focus();
        } else {
            window.classList.remove('active');
            button.classList.remove('active');
        }
    }
    
    closeChat() {
        this.isOpen = false;
        document.getElementById('chatbot-window').classList.remove('active');
        document.getElementById('chatbot-button').classList.remove('active');
    }
    
    async sendMessage() {
        const input = document.getElementById('chatbot-input');
        const message = input.value.trim();
        
        if (!message || this.isTyping) return;
        
        // Add user message
        this.addMessage('user', message);
        input.value = '';
        
        // Show typing indicator
        this.showTyping();
        
        try {
            // Call API
            const response = await fetch(this.apiEndpoint, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ message: message })
            });
            
            const data = await response.json();
            
            // Hide typing indicator
            this.hideTyping();
            
            if (data.success) {
                // Add bot response
                this.addMessage('bot', data.response);
            } else {
                // Show error
                this.addMessage('bot', '❌ ' + (data.error || 'Đã xảy ra lỗi. Vui lòng thử lại.'));
            }
            
        } catch (error) {
            console.error('ChatBot API Error:', error);
            this.hideTyping();
            this.addMessage('bot', '❌ Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.');
        }
    }
    
    addMessage(role, content) {
        const messagesContainer = document.getElementById('chatbot-messages');
        
        // Remove welcome message if exists
        const welcome = messagesContainer.querySelector('.chatbot-welcome');
        if (welcome) {
            welcome.remove();
        }
        
        const time = new Date().toLocaleTimeString('vi-VN', { 
            hour: '2-digit', 
            minute: '2-digit' 
        });
        
        const contextPath = this.getContextPath();
        const avatarContent = role === 'user' 
            ? `<img src="${contextPath}/img/trans_logo.png" alt="User">` 
            : `<img src="${contextPath}/img/trans_logo.png" alt="AI">`;
        
        const messageHTML = `
            <div class="chatbot-message ${role}">
                <div class="chatbot-message-avatar">
                    ${avatarContent}
                </div>
                <div class="chatbot-message-content">
                    ${this.formatMessage(content)}
                    <div class="chatbot-message-time">${time}</div>
                </div>
            </div>
        `;
        
        messagesContainer.insertAdjacentHTML('beforeend', messageHTML);
        
        // Scroll to bottom
        messagesContainer.scrollTop = messagesContainer.scrollHeight;
        
        // Save to history
        this.messages.push({ role, content, time });
        this.saveChatHistory();
    }
    
    formatMessage(text) {
        // Simple formatting: line breaks, bold, etc.
        return text
            .replace(/\n/g, '<br>')
            .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
            .replace(/\*(.*?)\*/g, '<em>$1</em>');
    }
    
    showTyping() {
        this.isTyping = true;
        const messagesContainer = document.getElementById('chatbot-messages');
        const contextPath = this.getContextPath();
        
        const typingHTML = `
            <div class="chatbot-message bot" id="chatbot-typing-indicator">
                <div class="chatbot-message-avatar">
                    <img src="${contextPath}/img/trans_logo.png" alt="AI">
                </div>
                <div class="chatbot-typing">
                    <div class="chatbot-typing-dots">
                        <div class="chatbot-typing-dot"></div>
                        <div class="chatbot-typing-dot"></div>
                        <div class="chatbot-typing-dot"></div>
                    </div>
                </div>
            </div>
        `;
        
        messagesContainer.insertAdjacentHTML('beforeend', typingHTML);
        messagesContainer.scrollTop = messagesContainer.scrollHeight;
        
        // Disable send button
        document.getElementById('chatbot-send').disabled = true;
    }
    
    hideTyping() {
        this.isTyping = false;
        const indicator = document.getElementById('chatbot-typing-indicator');
        if (indicator) {
            indicator.remove();
        }
        
        // Enable send button
        document.getElementById('chatbot-send').disabled = false;
    }
    
    saveChatHistory() {
        try {
            localStorage.setItem('liteflow_chat_history', JSON.stringify(this.messages));
        } catch (e) {
            console.warn('Failed to save chat history:', e);
        }
    }
    
    loadChatHistory() {
        try {
            const history = localStorage.getItem('liteflow_chat_history');
            if (history) {
                this.messages = JSON.parse(history);
                
                // Restore last 10 messages
                const recentMessages = this.messages.slice(-10);
                const messagesContainer = document.getElementById('chatbot-messages');
                
                // Remove welcome
                const welcome = messagesContainer.querySelector('.chatbot-welcome');
                if (welcome && recentMessages.length > 0) {
                    welcome.remove();
                }
                
                // Render messages
                const contextPath = this.getContextPath();
                recentMessages.forEach(msg => {
                    const avatarContent = msg.role === 'user' 
                        ? `<img src="${contextPath}/img/trans_logo.png" alt="User">` 
                        : `<img src="${contextPath}/img/trans_logo.png" alt="AI">`;
                    
                    const messageHTML = `
                        <div class="chatbot-message ${msg.role}">
                            <div class="chatbot-message-avatar">
                                ${avatarContent}
                            </div>
                            <div class="chatbot-message-content">
                                ${this.formatMessage(msg.content)}
                                <div class="chatbot-message-time">${msg.time}</div>
                            </div>
                        </div>
                    `;
                    messagesContainer.insertAdjacentHTML('beforeend', messageHTML);
                });
            }
        } catch (e) {
            console.warn('Failed to load chat history:', e);
        }
    }
}

// Initialize chatbot when DOM is ready
document.addEventListener('DOMContentLoaded', function() {
    window.liteflowChatBot = new LiteFlowChatBot();
});

