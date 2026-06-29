/**
 * menu.js — Logic riêng cho trang thực đơn
 */

document.addEventListener('DOMContentLoaded', () => {
    updateCartUI();
    initStickyNav();
    initCatNavHighlight();
    initHamburger();
    initBackToTop();
    initScrollReveal();

    // Enable add btn for Bơ đậu on menu page
    document.querySelectorAll('input[name="m-bo-dau-opt"]').forEach(radio => {
        radio.addEventListener('change', () => {
            const errMsg = document.getElementById('m-opt-error');
            if (errMsg) errMsg.classList.add('hidden');
        });
    });
});

/* --- Sticky cat nav highlight on scroll --- */
function initCatNavHighlight() {
    const sections = ['banh-mi', 'xoi', 'nuoc'];
    const navLinks = {};
    sections.forEach(id => {
        navLinks[id] = document.getElementById(`cat-nav-${id}`);
    });

    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                Object.values(navLinks).forEach(l => l && l.classList.remove('active'));
                const link = navLinks[entry.target.id];
                if (link) link.classList.add('active');
            }
        });
    }, { threshold: 0.3, rootMargin: '-130px 0px 0px 0px' });

    sections.forEach(id => {
        const el = document.getElementById(id);
        if (el) observer.observe(el);
    });
}

function initStickyNav() {
    const nav = document.getElementById('sticky-cat-nav');
    if (!nav) return;

    // Smooth scroll on cat nav click
    document.querySelectorAll('.cat-nav-link').forEach(link => {
        link.addEventListener('click', e => {
            e.preventDefault();
            const targetId = link.getAttribute('href').replace('#', '');
            const target = document.getElementById(targetId);
            if (target) {
                const offset = 130; // header + sticky nav height
                window.scrollTo({ top: target.offsetTop - offset, behavior: 'smooth' });
            }
        });
    });
}

/* --- Special add for Bơ đậu on menu page --- */
function addBoDauMenu() {
    const selected = document.querySelector('input[name="m-bo-dau-opt"]:checked');
    const errMsg = document.getElementById('m-opt-error');

    if (!selected) {
        document.querySelectorAll('#m-option-bo-dau .option-label').forEach(l => l.classList.add('error'));
        if (errMsg) errMsg.classList.remove('hidden');
        setTimeout(() => {
            document.querySelectorAll('#m-option-bo-dau .option-label').forEach(l => l.classList.remove('error'));
        }, 1500);
        showToast('⚠️ Vui lòng chọn Sữa hoặc Đường!', 'warn');
        return;
    }
    if (errMsg) errMsg.classList.add('hidden');
    const btn = document.getElementById('m-add-bo-dau');
    animateBtn(btn);
    addToCart('Bánh mì Bơ đậu', 10000, selected.value);
}

/* --- Size item add for menu page --- */
function addMenuSizeItem(name, itemKey) {
    const group = document.getElementById(`m-size-${itemKey.replace('m-', '')}`);
    if (!group) return;
    const activeBtn = group.querySelector('.size-btn.active');
    if (!activeBtn) { showToast('⚠️ Vui lòng chọn size!', 'warn'); return; }
    const price = parseInt(activeBtn.dataset.price);
    const size = activeBtn.dataset.size;
    addToCart(name, price, null, size);
}

/* --- Animate add btn --- */
function animateBtn(btn) {
    if (!btn) return;
    btn.classList.add('bounce');
    setTimeout(() => btn.classList.remove('bounce'), 350);
}

/* --- Scroll reveal --- */
function initScrollReveal() {
    const cards = document.querySelectorAll('.menu-product-card');
    const observer = new IntersectionObserver((entries) => {
        entries.forEach((entry, i) => {
            if (entry.isIntersecting) {
                setTimeout(() => {
                    entry.target.style.opacity = '1';
                    entry.target.style.transform = 'translateY(0)';
                }, i * 60);
                observer.unobserve(entry.target);
            }
        });
    }, { threshold: 0.1 });

    cards.forEach(card => {
        card.style.opacity = '0';
        card.style.transform = 'translateY(24px)';
        card.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
        observer.observe(card);
    });
}

/* --- Back to top --- */
function initBackToTop() {
    const btn = document.getElementById('back-to-top');
    if (!btn) return;
    window.addEventListener('scroll', () => {
        btn.classList.toggle('visible', window.scrollY > 400);
    }, { passive: true });
}

/* --- Hamburger (reuse from main) --- */
function initHamburger() {
    const hamburger = document.getElementById('hamburger-btn');
    const drawer = document.getElementById('mobile-drawer');
    const overlay = document.getElementById('drawer-overlay');
    const closeBtn = document.getElementById('drawer-close-btn');
    if (!hamburger || !drawer) return;
    function openDrawer() { drawer.classList.add('open'); hamburger.classList.add('open'); document.body.style.overflow = 'hidden'; }
    function closeDrawer() { drawer.classList.remove('open'); hamburger.classList.remove('open'); document.body.style.overflow = ''; }
    hamburger.addEventListener('click', () => drawer.classList.contains('open') ? closeDrawer() : openDrawer());
    if (overlay) overlay.addEventListener('click', closeDrawer);
    if (closeBtn) closeBtn.addEventListener('click', closeDrawer);
    drawer.querySelectorAll('.drawer-link').forEach(l => l.addEventListener('click', closeDrawer));
}
