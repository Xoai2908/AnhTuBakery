/**
 * cart.js — Quản lý giỏ hàng Bánh Mì Anh Tú
 * Lưu trong localStorage để giữ state khi điều hướng giữa các trang
 */

const CART_KEY = 'anhtubakery_cart';

/* ---- State ---- */
let cart = loadCart();

/* ---- Persistence ---- */
function loadCart() {
    try {
        const timeStr = localStorage.getItem('anhtubakery_cart_time');
        let savedCart = JSON.parse(localStorage.getItem(CART_KEY)) || [];
        console.log("[Cart Debug] loadCart loaded raw cart:", savedCart, "timeStr:", timeStr);
        if (timeStr) {
            const savedTime = parseInt(timeStr);
            const now = Date.now();
            const diff = now - savedTime;
            console.log("[Cart Debug] time diff:", diff, "limit:", 15 * 60 * 1000);
            if (diff > 15 * 60 * 1000) {
                console.log("[Cart Debug] Cart expired, clearing...");
                localStorage.removeItem(CART_KEY);
                localStorage.removeItem('anhtubakery_cart_time');
                return [];
            }
        }
        return savedCart;
    } catch (e) {
        console.error("[Cart Debug] loadCart error:", e);
        return [];
    }
}

function saveCart() {
    if (cart.length === 0) {
        localStorage.removeItem(CART_KEY);
        localStorage.removeItem('anhtubakery_cart_time');
    } else {
        localStorage.setItem(CART_KEY, JSON.stringify(cart));
        localStorage.setItem('anhtubakery_cart_time', Date.now().toString());
    }
}

/* ---- Cart Operations ---- */
function addToCart(name, price, option = null, size = null) {
    const key = buildKey(name, option, size);
    const existing = cart.find(i => i.key === key);

    if (existing) {
        existing.qty++;
    } else {
        cart.push({ key, name, price, option, size, qty: 1 });
    }

    saveCart();
    updateCartUI();
    showToast(`✅ Đã thêm "${name}" vào giỏ!`);
}

function removeFromCart(key) {
    cart = cart.filter(i => i.key !== key);
    saveCart();
    updateCartUI();
}

function changeQty(key, delta) {
    const item = cart.find(i => i.key === key);
    if (!item) return;
    item.qty += delta;
    if (item.qty <= 0) {
        removeFromCart(key);
        return;
    }
    saveCart();
    updateCartUI();
}

function clearCart() {
    cart = [];
    saveCart();
    updateCartUI();
}

function getCartCount() {
    return cart.reduce((sum, i) => sum + i.qty, 0);
}

function getCartSubtotal() {
    return cart.reduce((sum, i) => sum + i.price * i.qty, 0);
}

/* ---- Helpers ---- */
function buildKey(name, option, size) {
    return [name, option || '', size || ''].join('|');
}

function formatVND(amount) {
    return amount.toLocaleString('vi-VN') + 'đ';
}

/* ---- UI Updates ---- */
function updateCartUI() {
    const count = getCartCount();
    const subtotal = getCartSubtotal();

    // Float button
    const floatEl = document.getElementById('cart-float');
    const countEl = document.getElementById('cart-count');
    const totalEl = document.getElementById('cart-total-float');

    if (floatEl) {
        floatEl.style.display = count > 0 ? 'flex' : 'none';
        if (countEl) countEl.textContent = count;
        if (totalEl) totalEl.textContent = formatVND(subtotal);
    }

    // Cart items in drawer
    renderCartItems();

    // Summary
    const summaryEl = document.getElementById('cart-summary');
    const subtotalValEl = document.getElementById('cart-subtotal-val');
    if (summaryEl) summaryEl.style.display = count > 0 ? 'block' : 'none';
    if (subtotalValEl) subtotalValEl.textContent = formatVND(subtotal);
}

function renderCartItems() {
    const itemsEl = document.getElementById('cart-items');
    const emptyEl = document.getElementById('cart-empty');
    if (!itemsEl) return;

    itemsEl.innerHTML = '';

    if (cart.length === 0) {
        if (emptyEl) emptyEl.style.display = 'block';
        return;
    }
    if (emptyEl) emptyEl.style.display = 'none';

    cart.forEach(item => {
        const detail = [item.option, item.size === 'LARGE' ? 'Hộp lớn / Ly lớn' : item.size === 'SMALL' ? 'Hộp nhỏ / Ly nhỏ' : '']
            .filter(Boolean).join(', ');

        const el = document.createElement('div');
        el.className = 'cart-item';
        el.id = `cart-item-${CSS.escape(item.key)}`;
        el.innerHTML = `
            <div style="flex:1;">
                <div class="cart-item-name">${item.name}</div>
                ${detail ? `<div class="cart-item-detail">${detail}</div>` : ''}
            </div>
            <div class="cart-item-qty">
                <button class="qty-btn" onclick="changeQty('${item.key.replace(/'/g, "\\'")}', -1)" aria-label="Giảm số lượng">−</button>
                <span class="qty-num">${item.qty}</span>
                <button class="qty-btn" onclick="changeQty('${item.key.replace(/'/g, "\\'")}', 1)" aria-label="Tăng số lượng">+</button>
            </div>
            <div class="cart-item-price">${formatVND(item.price * item.qty)}</div>
            <button class="cart-item-remove" onclick="removeFromCart('${item.key.replace(/'/g, "\\'")}')" aria-label="Xóa món">✕</button>
        `;
        itemsEl.appendChild(el);
    });
}

/* ---- Cart Drawer Toggle ---- */
function toggleCart() {
    const drawer = document.getElementById('cart-drawer');
    if (!drawer) return;
    const isOpen = drawer.classList.contains('open');
    drawer.classList.toggle('open', !isOpen);
    drawer.setAttribute('aria-hidden', isOpen ? 'true' : 'false');
    document.body.style.overflow = isOpen ? '' : 'hidden';
}

/* ---- Special add functions for products with options ---- */

function addBoDau() {
    const selected = document.querySelector('input[name="bo-dau-opt"]:checked');
    if (!selected) {
        // Highlight error
        document.querySelectorAll('.option-label').forEach(l => l.classList.add('error'));
        setTimeout(() => document.querySelectorAll('.option-label').forEach(l => l.classList.remove('error')), 1500);
        showToast('⚠️ Vui lòng chọn Sữa hoặc Đường!', 'warn');
        return;
    }
    const btn = document.getElementById('add-bo-dau');
    if (btn) { btn.classList.add('bounce'); setTimeout(() => btn.classList.remove('bounce'), 350); }
    addToCart('Bánh mì Bơ đậu', 10000, selected.value);
}

// Enable add button when option selected
document.addEventListener('DOMContentLoaded', () => {
    document.querySelectorAll('input[name="bo-dau-opt"]').forEach(radio => {
        radio.addEventListener('change', () => {
            const btn = document.getElementById('add-bo-dau');
            if (btn) btn.disabled = false;
        });
    });
});

function selectSize(btn, itemKey) {
    // Find parent size-group and update active
    const group = btn.closest('.size-group');
    if (!group) return;
    group.querySelectorAll('.size-btn').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');

    // Update displayed price
    const priceEl = document.getElementById(`price-${itemKey}`);
    if (priceEl) {
        const price = parseInt(btn.dataset.price);
        priceEl.textContent = formatVND(price);
    }
}

function addSizeItem(name, itemKey) {
    const group = document.getElementById(`size-${itemKey}`);
    if (!group) return;
    const activeBtn = group.querySelector('.size-btn.active');
    if (!activeBtn) { showToast('⚠️ Vui lòng chọn size!', 'warn'); return; }

    const price = parseInt(activeBtn.dataset.price);
    const size = activeBtn.dataset.size;

    const addBtn = document.getElementById(`add-${itemKey}`);
    if (addBtn) { addBtn.classList.add('bounce'); setTimeout(() => addBtn.classList.remove('bounce'), 350); }

    addToCart(name, price, null, size);
}

/* ---- Toast ---- */
let toastTimer;
function showToast(msg, type = 'success') {
    const toast = document.getElementById('toast');
    if (!toast) return;
    toast.textContent = msg;
    toast.className = 'toast show';
    if (type === 'warn') toast.style.background = '#B45309';
    else toast.style.background = '#92400E';

    clearTimeout(toastTimer);
    toastTimer = setTimeout(() => { toast.className = 'toast'; }, 2500);
}

/* ---- Export for order page ---- */
function addBanhMiWithToppings(name, basePrice, itemKey) {
    const checkboxes = document.querySelectorAll(`input[name="topping-${itemKey}"]:checked`);
    let addedPrice = 0;
    const toppings = [];

    checkboxes.forEach(cb => {
        addedPrice += parseInt(cb.dataset.price || 0);
        toppings.push(cb.value);
    });

    const finalPrice = basePrice + addedPrice;
    const optionText = toppings.length > 0 ? toppings.join(', ') : null;

    addToCart(name, finalPrice, optionText);

    // Uncheck all checkboxes after adding
    document.querySelectorAll(`input[name="topping-${itemKey}"]`).forEach(cb => cb.checked = false);
}

window.BakeryCart = {
    getCart: () => cart,
    getCount: getCartCount,
    getSubtotal: getCartSubtotal,
    add: addToCart,
    addBanhMiWithToppings: addBanhMiWithToppings,
    remove: removeFromCart,
    changeQty,
    clear: clearCart,
    formatVND
};
