 $(function() { 
        $('.quotationbtn').tooltip({
            trigger: 'click',
            placement: 'bottom'
        });

        function setTooltip(message) {
            $('.quotationbtn').tooltip('hide')
            .attr('data-original-title', message)
            .tooltip('show');
        }

        function hideTooltip() {
          setTimeout(function() {
            $('.quotationbtn').tooltip('hide');
          }, 1000);
        }

        // clipboard.js
        var clipboard = new ClipboardJS('.quotationbtn', {
            target: function(trigger) {
                return trigger.previousElementSibling;
            }
        });

        clipboard.on('success', function(e) {
            setTooltip('Copied!');
            hideTooltip();
        });
        
        clipboard.on('error', function(e) {
            setTooltip('Failed!');
            hideTooltip();
        });
       });