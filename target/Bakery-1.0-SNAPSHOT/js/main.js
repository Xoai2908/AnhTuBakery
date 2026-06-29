/**
 * main.js — Điều hướng và tương tác trang chủ Bánh Mì Anh Tú
 */

document.addEventListener('DOMContentLoaded', () => {

    /* ========== INIT ========== */
    updateCartUI();
    initNavHighlight();
    initHamburger();
    initMenuTabs();
    initScrollReveal();
    initBackToTop();
    initSmoothScroll();

    /* ========== HAMBURGER MENU ========== */
    function initHamburger() {
        const hamburger = document.getElementById('hamburger-btn');
        const drawer = document.getElementById('mobile-drawer');
        const overlay = document.getElementById('drawer-overlay');
        const closeBtn = document.getElementById('drawer-close-btn');

        if (!hamburger || !drawer) return;

        function openDrawer() {
            drawer.classList.add('open');
            hamburger.classList.add('open');
            hamburger.setAttribute('aria-expanded', 'true');
            document.body.style.overflow = 'hidden';
        }
        function closeDrawer() {
            drawer.classList.remove('open');
            hamburger.classList.remove('open');
            hamburger.setAttribute('aria-expanded', 'false');
            document.body.style.overflow = '';
        }

        hamburger.addEventListener('click', () => {
            drawer.classList.contains('open') ? closeDrawer() : openDrawer();
        });
        if (overlay) overlay.addEventListener('click', closeDrawer);
        if (closeBtn) closeBtn.addEventListener('click', closeDrawer);

        // Close on link click
        drawer.querySelectorAll('.drawer-link').forEach(link => {
            link.addEventListener('click', closeDrawer);
        });

        // Close on Escape
        document.addEventListener('keydown', e => {
            if (e.key === 'Escape') { closeDrawer(); toggleCart(); }
        });
    }

    /* ========== MENU TABS ========== */
    function initMenuTabs() {
        const tabs = document.querySelectorAll('.menu-tab');
        if (!tabs.length) return;

        tabs.forEach(tab => {
            tab.addEventListener('click', () => {
                const target = tab.dataset.tab;

                // Update tab buttons
                tabs.forEach(t => {
                    t.classList.remove('active');
                    t.setAttribute('aria-selected', 'false');
                });
                tab.classList.add('active');
                tab.setAttribute('aria-selected', 'true');

                // Show/hide panels
                document.querySelectorAll('[id^="tab-content-"]').forEach(panel => {
                    panel.classList.add('hidden');
                });
                const panel = document.getElementById(`tab-content-${target}`);
                if (panel) {
                    panel.classList.remove('hidden');
                    // Trigger reveal animation
                    panel.querySelectorAll('.product-card').forEach((card, i) => {
                        card.style.animation = 'none';
                        card.style.opacity = '0';
                        card.style.transform = 'translateY(20px)';
                        setTimeout(() => {
                            card.style.animation = '';
                            card.style.transition = `opacity 0.4s ${i * 0.07}s ease, transform 0.4s ${i * 0.07}s ease`;
                            card.style.opacity = '1';
                            card.style.transform = 'translateY(0)';
                        }, 10);
                    });
                }
            });
        });
    }

    /* ========== NAV HIGHLIGHT ========== */
    function initNavHighlight() {
        const path = window.location.pathname;
        document.querySelectorAll('.nav-link').forEach(link => {
            link.classList.remove('active');
            const href = link.getAttribute('href');
            if (href && path.endsWith(href)) link.classList.add('active');
        });

        // Intersection observer for sections (homepage)
        if (path.endsWith('index.jsp') || path === '/' || path.endsWith('/')) {
            const sections = document.querySelectorAll('section[id]');
            const navLinks = document.querySelectorAll('.nav-link[href^="#"]');

            const observer = new IntersectionObserver((entries) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        navLinks.forEach(link => {
                            link.classList.remove('active');
                            if (link.getAttribute('href') === `#${entry.target.id}`) {
                                link.classList.add('active');
                            }
                        });
                    }
                });
            }, { threshold: 0.4 });

            sections.forEach(s => observer.observe(s));
        }
    }

    /* ========== SCROLL REVEAL ========== */
    function initScrollReveal() {
        const revealEls = document.querySelectorAll(
            '.product-card, .step-card, .contact-card, .about-feat, .stat-item, .delivery-card'
        );

        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('reveal', 'visible');
                    observer.unobserve(entry.target);
                }
            });
        }, { threshold: 0.15 });

        revealEls.forEach((el, i) => {
            el.classList.add('reveal');
            el.style.transitionDelay = `${i * 0.06}s`;
            observer.observe(el);
        });
    }

    /* ========== BACK TO TOP ========== */
    function initBackToTop() {
        const btn = document.getElementById('back-to-top');
        if (!btn) return;

        window.addEventListener('scroll', () => {
            btn.classList.toggle('visible', window.scrollY > 400);
        }, { passive: true });
    }

    /* ========== SMOOTH SCROLL (for # links) ========== */
    function initSmoothScroll() {
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', e => {
                const target = document.querySelector(anchor.getAttribute('href'));
                if (target) {
                    e.preventDefault();
                    const headerH = document.getElementById('site-header')?.offsetHeight || 70;
                    window.scrollTo({
                        top: target.offsetTop - headerH,
                        behavior: 'smooth'
                    });
                }
            });
        });
    }

    /* ========== HEADER SCROLL EFFECT ========== */
    const header = document.getElementById('site-header');
    if (header) {
        window.addEventListener('scroll', () => {
            header.style.boxShadow = window.scrollY > 20
                ? '0 4px 24px rgba(0,0,0,0.4)'
                : '0 2px 20px rgba(0,0,0,0.3)';
        }, { passive: true });
    }

});
