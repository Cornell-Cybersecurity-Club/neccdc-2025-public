const img = document.getElementById("refreshing-image");
const errorMessage = document.getElementById("error-message");
const loadingSpinner = document.querySelector(".loading-spinner");

function refreshImage() {
    img.style.opacity = "0.3";
    loadingSpinner.style.display = "block";
    const newImage = new Image();
    newImage.src = "/static/image.png?t=" + new Date().getTime();
    
    newImage.onload = () => {
        img.src = newImage.src;
        img.style.opacity = "1";
        loadingSpinner.style.display = "none";
        hideError();
    };
    
    newImage.onerror = () => {
        loadingSpinner.style.display = "none";
        showError();
    };
}

function showError(message) {
    errorMessage.querySelector(".error-text").textContent = 
        message || "Failed to load graph image. Please try again later.";
    img.style.display = 'none';
    errorMessage.style.display = 'block';
}

function hideError() {
    img.style.display = 'block';
    errorMessage.style.display = 'none';
}

img.onerror = () => showError();
img.onload = hideError;

// Initial load
refreshImage();

// Refresh image every 60 seconds
setInterval(refreshImage, 60000);
