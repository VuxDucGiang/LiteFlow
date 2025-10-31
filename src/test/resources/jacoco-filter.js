// Filter JaCoCo report to hide files with coverage < 30%
(function() {
    'use strict';
    
    function hideLowCoverage() {
        // Ẩn các dòng trong bảng có coverage < 30%
        var rows = document.querySelectorAll('table.coverage tbody tr, table[id^="el"] tbody tr');
        rows.forEach(function(row) {
            var cells = row.querySelectorAll('td');
            if (cells.length >= 3) {
                // Coverage thường ở cột cuối hoặc gần cuối
                for (var i = cells.length - 1; i >= Math.max(0, cells.length - 3); i--) {
                    var cell = cells[i];
                    var text = cell.textContent.trim();
                    // Tìm percentage coverage (ví dụ: "45%" hoặc "45% (123/456)")
                    var match = text.match(/(\d+)%/);
                    if (match) {
                        var coverage = parseInt(match[1]);
                        if (coverage < 30) {
                            row.style.display = 'none';
                            break;
                        }
                    }
                }
            }
        });
    }
    
    // Chạy khi DOM ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', hideLowCoverage);
    } else {
        hideLowCoverage();
    }
})();

