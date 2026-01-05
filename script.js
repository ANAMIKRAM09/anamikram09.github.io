/* =========================================
   1. NAVIGATION MENU LOGIC (With Outside Click Fix)
   ========================================= */
const menuIconDiv = document.querySelector('.menu-icon');
const menuIcon = menuIconDiv.querySelector('i');
const mobileNav = document.getElementById('mobile-nav');

// --- A. Toggle Button Click ---
menuIconDiv.addEventListener('click', (event) => {
    
    event.stopPropagation(); 

    mobileNav.classList.toggle('active');
    menuIconDiv.classList.toggle('rotate');

    if (mobileNav.classList.contains('active')) {
        menuIcon.classList.remove('fa-bars');
        menuIcon.classList.add('fa-times');
    } else {
        menuIcon.classList.remove('fa-times');
        menuIcon.classList.add('fa-bars');
    }
});

// --- B. Outside Click (Close Menu) ---
document.addEventListener('click', (event) => {
    
    if (mobileNav.classList.contains('active') && !mobileNav.contains(event.target)) {
        
        mobileNav.classList.remove('active');
        menuIconDiv.classList.remove('rotate');
        menuIcon.classList.remove('fa-times');
        menuIcon.classList.add('fa-bars');
    }
});


/* =========================================
   2. POPUP MODAL LOGIC
   ========================================= */

function openModal(modalId) {
    document.getElementById(modalId).style.display = "flex";
}

function closeModal(modalId) {
    document.getElementById(modalId).style.display = "none";
}