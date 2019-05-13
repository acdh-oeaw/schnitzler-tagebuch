 // Code taken from ARCHE Website
 
 $(function() { 
     
    
    $(document ).delegate( "#copyLinkInputBtn", "click", function(e) {
        var URLtoCopy = $(this).data("copyuri");
        var result = copyToClipboard(URLtoCopy);
        if (result) {
	        $('#copyLinkTextfield').val("URL is copied to clipboard!");
	        setTimeout(function() { $('#copyLinkTextfield').val(URLtoCopy); }, 2000);
        }
    });
    
    
    $(document).on({
    mouseenter: function () {
        $(this).find('#copyLinkTextfield-wrapper').fadeIn();
    },
    mouseleave: function () {
        $(this).find('#copyLinkTextfield-wrapper').fadeOut();
    }
}, '#res-act-button-copy-url');
     
     
     $(document ).delegate( "#copy-cite-btn", "click", function(e) {    
         var URLtoCopy = $('.cite-content.active').html();
         var result = copyToClipboard(URLtoCopy);
        if (result) {
            $('#copy-cite-btn-confirmation').fadeIn(100);
            setTimeout(function() { $('#copy-cite-btn-confirmation').fadeOut(200); }, 2000);
        }
     });
    
});

// Copies a string to the clipboard. Must be called from within an event handler such as click.
// May return false if it failed, but this is not always
// possible. Browser support for Chrome 43+, Firefox 42+, Edge and IE 10+, Safari 10+.
// IE: The clipboard feature may be disabled by an adminstrator. By default a prompt is
// shown the first time the clipboard is used (per session).
function copyToClipboard(text) {
    if (window.clipboardData && window.clipboardData.setData) {
        // IE specific code path to prevent textarea being shown while dialog is visible.
        return clipboardData.setData("Text", text); 

    } else if (document.queryCommandSupported && document.queryCommandSupported("copy")) {
        var textarea = document.createElement("textarea");
        textarea.textContent = text;
        textarea.style.position = "fixed";  // Prevent scrolling to bottom of page in MS Edge.
        document.body.appendChild(textarea);
        textarea.select();
        try {
            return document.execCommand("copy");  // Security exception may be thrown by some browsers.
        } catch (ex) {
            console.warn("Copy to clipboard failed.", ex);
            return false;
        } finally {
            document.body.removeChild(textarea);
        }
    }
}