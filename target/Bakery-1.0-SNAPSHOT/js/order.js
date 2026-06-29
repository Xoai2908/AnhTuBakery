/**
 * order.js — Xử lý trang đặt hàng lẻ
 * Bao gồm: hiển thị giỏ hàng, chọn hình thức nhận, tính phí ship, xác nhận đơn
 */

/* ===== Constants ===== */
// Tọa độ lò bánh (cấu hình thực tế trong application.yml)
const BAKERY_LAT = 16.447500;
const BAKERY_LNG = 107.596100;

/* Phí ship theo bậc thang */
const SHIPPING = {
    baseFee: 10000,
    tier2Start: 2.0, tier2Rate: 3500,
    tier3Start: 5.0, tier3Rate: 4000,
    tier4Start: 10.0, tier4Rate: 5000,
    warningDist: 50.0
};

let currentShippingFee = 0;
let currentDeliveryMethod = null;

console.log("[Order Debug] order.js root execution. ReadyState:", document.readyState);

/* ===== INIT ===== */
function initOrderPage() {
    console.log("[Order Debug] initOrderPage starting...");
    initHamburger();
    renderOrderCart();
    initDeliveryMethodToggle();
    initAddressAutoGeocode();
    initFormValidation();

    // Auto-update QR code in summary block when customer changes phone number
    document.getElementById('customer-phone')?.addEventListener('input', renderSummary);
}

if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initOrderPage);
} else {
    initOrderPage();
}

/* ===== HAMBURGER (duplicated for standalone pages) ===== */
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

/* ===== RENDER ORDER CART ===== */
function renderOrderCart() {
    console.log("[Order Debug] renderOrderCart starting...");
    const cartList = document.getElementById('order-cart-list');
    const emptyEl = document.getElementById('order-cart-empty');
    const addMoreLink = document.getElementById('add-more-link');
    console.log("[Order Debug] window.BakeryCart:", window.BakeryCart);
    const cartItems = window.BakeryCart ? window.BakeryCart.getCart() : (JSON.parse(localStorage.getItem('anhtubakery_cart')) || []);
    console.log("[Order Debug] loaded cartItems:", cartItems);

    if (!cartItems || cartItems.length === 0) {
        console.log("[Order Debug] cartItems is empty!");
        if (emptyEl) emptyEl.style.display = 'flex';
        if (cartList) cartList.style.display = 'none';
        if (addMoreLink) addMoreLink.style.display = 'none';
        return;
    }

    if (emptyEl) emptyEl.style.display = 'none';
    if (cartList) cartList.style.display = 'flex';
    if (addMoreLink) addMoreLink.style.display = 'inline-flex';

    cartList.innerHTML = '';
    cartItems.forEach(item => {
        const detail = [
            item.option,
            item.size === 'LARGE' ? 'Hộp lớn / Ly lớn' : item.size === 'SMALL' ? 'Hộp nhỏ / Ly nhỏ' : ''
        ].filter(Boolean).join(', ');

        const el = document.createElement('div');
        el.className = 'order-item';
        el.innerHTML = `
            <div style="flex:1">
                <div class="order-item-name">${item.name}</div>
                ${detail ? `<div class="order-item-detail">${detail}</div>` : ''}
            </div>
            <div class="order-item-qty">
                <button class="o-qty-btn" onclick="changeOrderQty('${item.key.replace(/'/g, "\\'")}', -1)">−</button>
                <span class="o-qty-num">${item.qty}</span>
                <button class="o-qty-btn" onclick="changeOrderQty('${item.key.replace(/'/g, "\\'")}', 1)">+</button>
            </div>
            <div class="order-item-price">${formatVND(item.price * item.qty)}</div>
            <button class="order-item-remove" onclick="removeOrderItem('${item.key.replace(/'/g, "\\'")}')">✕</button>
        `;
        cartList.appendChild(el);
    });

    renderSummary();
}

function changeOrderQty(key, delta) {
    if (window.BakeryCart) window.BakeryCart.changeQty(key, delta);
    renderOrderCart();
}
function removeOrderItem(key) {
    if (window.BakeryCart) window.BakeryCart.remove(key);
    renderOrderCart();
}

/* ===== SUMMARY ===== */
function renderSummary() {
    const cartItems = window.BakeryCart ? window.BakeryCart.getCart() : [];
    const subtotal = cartItems.reduce((s, i) => s + i.price * i.qty, 0);

    const summaryItems = document.getElementById('summary-items');
    if (summaryItems) {
        summaryItems.innerHTML = '';
        cartItems.forEach(item => {
            const detail = [item.option, item.size === 'LARGE' ? 'Lớn' : item.size === 'SMALL' ? 'Nhỏ' : ''].filter(Boolean).join(' · ');
            const el = document.createElement('div');
            el.className = 'summary-item';
            el.innerHTML = `
                <span class="summary-item-name">${item.name}${detail ? ` <small>(${detail})</small>` : ''} ×${item.qty}</span>
                <span class="summary-item-price">${formatVND(item.price * item.qty)}</span>
            `;
            summaryItems.appendChild(el);
        });
    }

    const shipFeeEl = document.getElementById('summary-ship-fee');
    const totalEl = document.getElementById('summary-total');

    document.getElementById('summary-subtotal').textContent = formatVND(subtotal);
    if (shipFeeEl) {
        if (currentDeliveryMethod === 'TU_LAY') shipFeeEl.textContent = 'Miễn phí';
        else if (currentDeliveryMethod === 'GIAO_HANG' && currentShippingFee > 0) shipFeeEl.textContent = formatVND(currentShippingFee);
        else shipFeeEl.textContent = '—';
    }
    if (totalEl) {
        const total = subtotal + (currentDeliveryMethod === 'GIAO_HANG' ? currentShippingFee : 0);
        totalEl.textContent = formatVND(total);

        // Update real-time summary QR code
        const qrSummaryImg = document.getElementById('qr-summary-image');
        const qrSummaryContent = document.getElementById('qr-summary-content');
        if (qrSummaryImg && total > 0) {
            const phone = document.getElementById('customer-phone')?.value.trim() || 'KHACH';
            const contentVal = `ANHTUBAKERY ${phone}`;
            if (qrSummaryContent) qrSummaryContent.textContent = contentVal;

            const qrUrl = 'https://img.vietqr.io/image/BIDV-8821037502-compact2.png'
                + '?amount=' + total
                + '&addInfo=' + encodeURIComponent(contentVal)
                + '&accountName=VO%20HO%20UYEN%20NHI';
            qrSummaryImg.src = qrUrl;

            document.getElementById('qr-note')?.classList.remove('hidden');
        } else {
            document.getElementById('qr-note')?.classList.add('hidden');
        }
    }
}

/* ===== DELIVERY METHOD TOGGLE ===== */
function initDeliveryMethodToggle() {
    const pickupRadio = document.getElementById('method-pickup');
    const shipRadio = document.getElementById('method-ship');

    function toggle() {
        const method = document.querySelector('input[name="delivery-method"]:checked')?.value;
        currentDeliveryMethod = method || null;

        const fgPickupTime = document.getElementById('fg-pickup-time');
        const fgAddress = document.getElementById('fg-address');
        const shipFeeResult = document.getElementById('ship-fee-result');

        if (method === 'TU_LAY') {
            fgPickupTime?.classList.remove('hidden');
            fgAddress?.classList.add('hidden');
            shipFeeResult?.classList.add('hidden');
            currentShippingFee = 0;
        } else if (method === 'GIAO_HANG') {
            fgPickupTime?.classList.add('hidden');
            fgAddress?.classList.remove('hidden');
        }

        document.getElementById('delivery-method-error')?.classList.add('hidden');
        renderSummary();
    }

    pickupRadio?.addEventListener('change', toggle);
    shipRadio?.addEventListener('change', toggle);
}

/* ===== AUTO GEOCODE FROM ADDRESS ===== */
let geocodeTimer;
let lastGeocodedAddress = '';

function initAddressAutoGeocode() {
    const addressInput = document.getElementById('delivery-address');
    if (!addressInput) { console.warn('[Geocode] delivery-address not found'); return; }

    console.log('[Geocode] Auto-geocode initialized');

    function onAddressChange() {
        clearTimeout(geocodeTimer);
        const address = addressInput.value.trim();
        console.log('[Geocode] Address changed:', address, '(length:', address.length, ')');

        // Reset if address cleared or too short
        if (address.length < 5) {
            resetGeocodeState();
            return;
        }

        // Debounce 600ms after user stops typing
        geocodeTimer = setTimeout(() => geocodeFromAddress(address), 600);
    }

    // Listen for multiple events to catch all input methods
    addressInput.addEventListener('input', onAddressChange);
    addressInput.addEventListener('change', onAddressChange); // catches autocomplete
    addressInput.addEventListener('blur', () => {
        const address = addressInput.value.trim();
        if (address.length >= 5 && address !== lastGeocodedAddress) {
            clearTimeout(geocodeTimer);
            geocodeFromAddress(address);
        }
    });
}

function resetGeocodeState() {
    document.getElementById('lat').value = '';
    document.getElementById('lng').value = '';
    currentShippingFee = 0;

    const statusEl = document.getElementById('geocode-status');
    const resultEl = document.getElementById('ship-fee-result');
    if (statusEl) statusEl.classList.add('hidden');
    if (resultEl) resultEl.classList.add('hidden');

    lastGeocodedAddress = '';
    renderSummary();
}

function geocodeFromAddress(address) {
    // Skip if same address already geocoded
    if (address === lastGeocodedAddress) {
        console.log('[Geocode] Skipping - same address already geocoded');
        return;
    }

    console.log('[Geocode] Geocoding address:', address);

    const statusEl = document.getElementById('geocode-status');
    const statusIcon = document.getElementById('geocode-status-icon');
    const statusText = document.getElementById('geocode-status-text');

    // Show loading
    if (statusEl) {
        statusEl.classList.remove('hidden', 'geocode-success', 'geocode-error');
        statusEl.classList.add('geocode-loading');
        statusIcon.textContent = '⏳';
        statusText.textContent = 'Đang tra cứu vị trí...';
    }

    // Append context for better accuracy
    const searchQuery = address.includes('Huế') || address.includes('Hue')
        ? address + ', Việt Nam'
        : address + ', Huế, Việt Nam';

    var urlParts = [];
    urlParts.push('https://nominatim.openstreetmap.org/search');
    urlParts.push('?q=');
    urlParts.push(encodeURIComponent(searchQuery));
    urlParts.push(String.fromCharCode(38) + 'format=json');
    urlParts.push(String.fromCharCode(38) + 'limit=1');
    urlParts.push(String.fromCharCode(38) + 'addressdetails=1');
    urlParts.push(String.fromCharCode(38) + 'countrycodes=vn');
    const url = urlParts.join('');

    console.log('[Geocode] Fetching:', url);

    fetch(url, {
        headers: { 'Accept-Language': 'vi' }
    })
    .then(res => {
        console.log('[Geocode] Response status:', res.status);
        if (!res.ok) throw new Error('Network error: ' + res.status);
        return res.json();
    })
    .then(data => {
        console.log('[Geocode] Data received:', data);
        if (data && data.length > 0) {
            const result = data[0];
            const lat = parseFloat(result.lat).toFixed(6);
            const lng = parseFloat(result.lon).toFixed(6);

            console.log('[Geocode] Found:', lat, lng, result.display_name);

            document.getElementById('lat').value = lat;
            document.getElementById('lng').value = lng;
            lastGeocodedAddress = address;

            // Calculate & show ship fee
            calculateAndShowShipFee();

            // Show success
            if (statusEl) {
                statusEl.classList.remove('geocode-loading', 'geocode-error');
                statusEl.classList.add('geocode-success');
                statusIcon.textContent = '✅';
                statusText.innerHTML = '<strong>' + result.display_name + '</strong>';
            }
        } else {
            console.warn('[Geocode] No results for:', searchQuery);
            resetGeocodeState();
            if (statusEl) {
                statusEl.classList.remove('hidden', 'geocode-loading', 'geocode-success');
                statusEl.classList.add('geocode-error');
                statusIcon.textContent = '❌';
                statusText.textContent = 'Không tìm thấy địa chỉ. Vui lòng nhập chi tiết hơn (vd: số nhà, đường, phường).';
            }
        }
    })
    .catch(err => {
        console.error('[Geocode Error]', err);
        if (statusEl) {
            statusEl.classList.remove('hidden', 'geocode-loading', 'geocode-success');
            statusEl.classList.add('geocode-error');
            statusIcon.textContent = '⚠️';
            statusText.textContent = 'Lỗi kết nối. Phí ship sẽ được tính sau khi xác nhận.';
        }
    });
}

function calculateAndShowShipFee() {
    const lat = parseFloat(document.getElementById('lat')?.value);
    const lng = parseFloat(document.getElementById('lng')?.value);

    if (isNaN(lat) || isNaN(lng)) return;
    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) return;

    const distKm = haversine(BAKERY_LAT, BAKERY_LNG, lat, lng);
    const fee = calcShipFee(distKm);
    currentShippingFee = fee;

    const resultEl = document.getElementById('ship-fee-result');
    const distEl = document.getElementById('ship-distance');
    const feeEl = document.getElementById('ship-fee-val');
    const warnEl = document.getElementById('ship-warning');

    if (resultEl) resultEl.classList.remove('hidden');
    if (distEl) distEl.textContent = `~${distKm.toFixed(1)} km`;
    if (feeEl) feeEl.textContent = formatVND(fee);
    if (warnEl) {
        warnEl.classList.toggle('hidden', distKm <= SHIPPING.warningDist);
    }

    renderSummary();
}

/* ===== HAVERSINE FORMULA ===== */
function haversine(lat1, lon1, lat2, lon2) {
    const R = 6371;
    const dLat = toRad(lat2 - lat1);
    const dLon = toRad(lon2 - lon1);
    const a = Math.sin(dLat/2)**2 + Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLon/2)**2;
    return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
}
function toRad(deg) { return deg * Math.PI / 180; }

/* ===== SHIPPING FEE CALC ===== */
function calcShipFee(d) {
    let fee;
    if (d <= 2.0) fee = SHIPPING.baseFee;
    else if (d <= 5.0) fee = SHIPPING.baseFee + (d - 2.0) * SHIPPING.tier2Rate;
    else if (d <= 10.0) fee = (SHIPPING.baseFee + 3.0 * SHIPPING.tier2Rate) + (d - 5.0) * SHIPPING.tier3Rate;
    else fee = (SHIPPING.baseFee + 3.0 * SHIPPING.tier2Rate + 5.0 * SHIPPING.tier3Rate) + (d - 10.0) * SHIPPING.tier4Rate;
    return Math.ceil(fee / 500) * 500; // Round up to nearest 500đ
}

/* ===== FORM VALIDATION ===== */
function initFormValidation() {
    document.getElementById('customer-name')?.addEventListener('blur', validateName);
    document.getElementById('customer-phone')?.addEventListener('blur', validatePhone);
}
function validateName() {
    const val = document.getElementById('customer-name')?.value.trim();
    const err = document.getElementById('err-name');
    const input = document.getElementById('customer-name');
    const valid = val && val.length > 0;
    input?.classList.toggle('error', !valid);
    err?.classList.toggle('hidden', valid);
    return valid;
}
function validatePhone() {
    const val = document.getElementById('customer-phone')?.value.trim();
    const err = document.getElementById('err-phone');
    const input = document.getElementById('customer-phone');
    const valid = /^\d{10}$/.test(val);
    input?.classList.toggle('error', !valid);
    err?.classList.toggle('hidden', valid);
    return valid;
}

/* ===== SUBMIT ORDER ===== */
function submitOrder() {
    const cart = window.BakeryCart ? window.BakeryCart.getCart() : [];
    let hasError = false;

    // Check cart
    if (cart.length === 0) {
        showToast('⚠️ Giỏ hàng đang trống!', 'warn');
        return;
    }

    // Validate delivery method
    const method = document.querySelector('input[name="delivery-method"]:checked')?.value;
    if (!method) {
        document.getElementById('delivery-method-error')?.classList.remove('hidden');
        document.getElementById('section-delivery')?.scrollIntoView({ behavior: 'smooth', block: 'center' });
        showToast('⚠️ Vui lòng chọn hình thức nhận hàng!', 'warn');
        return;
    }

    // Validate name & phone
    if (!validateName()) hasError = true;
    if (!validatePhone()) hasError = true;

    if (hasError) {
        document.getElementById('section-customer-info')?.scrollIntoView({ behavior: 'smooth', block: 'start' });
        showToast('⚠️ Vui lòng kiểm tra lại thông tin!', 'warn');
        return;
    }

    // Validate delivery-specific fields
    if (method === 'GIAO_HANG') {
        const address = document.getElementById('delivery-address')?.value.trim();

        if (!address) {
            document.getElementById('delivery-address')?.classList.add('error');
            document.getElementById('err-address')?.classList.remove('hidden');
            showToast('⚠️ Vui lòng nhập địa chỉ giao hàng!', 'warn');
            return;
        }

        const lat = parseFloat(document.getElementById('lat')?.value);
        const lng = parseFloat(document.getElementById('lng')?.value);
        if (isNaN(lat) || isNaN(lng)) {
            showToast('⚠️ Chưa xác định được vị trí từ địa chỉ. Vui lòng kiểm tra lại địa chỉ.', 'warn');
            document.getElementById('delivery-address')?.focus();
            return;
        }
        if (currentShippingFee === 0) calculateAndShowShipFee();
    } else if (method === 'TU_LAY') {
        const pickupTimeVal = document.getElementById('pickup-time')?.value;
        if (pickupTimeVal) {
            const now = new Date();
            const [hours, minutes] = pickupTimeVal.split(':').map(Number);
            const targetTime = new Date();
            targetTime.setHours(hours, minutes, 0, 0);

            // Calculate difference in minutes (must be today and strictly at least 10 minutes in the future)
            const diffMs = targetTime - now;
            const diffMins = Math.floor(diffMs / 1000 / 60);

            if (diffMins < 10) {
                showToast('⚠️ Thời gian đến lấy phải thuộc ngày hôm nay và sau thời gian hiện tại tối thiểu 10 phút!', 'warn');
                document.getElementById('pickup-time')?.focus();
                return;
            }
        }
    }

    // Show confirmation modal
    openConfirmModal();
}

/* ===== CONFIRM MODAL ===== */
function openConfirmModal() {
    const cart = window.BakeryCart ? window.BakeryCart.getCart() : [];
    const subtotal = cart.reduce((s, i) => s + i.price * i.qty, 0);
    const method = document.querySelector('input[name="delivery-method"]:checked')?.value;
    const shipFee = method === 'GIAO_HANG' ? currentShippingFee : 0;
    const total = subtotal + shipFee;
    const name = document.getElementById('customer-name')?.value.trim();
    const phone = document.getElementById('customer-phone')?.value.trim();
    const address = document.getElementById('delivery-address')?.value.trim() || '';
    const pickupTime = document.getElementById('pickup-time')?.value || '';
    const note = document.getElementById('order-note')?.value.trim() || '';

    const methodLabel = method === 'TU_LAY' ? '🏠 Tự đến lấy tại quán' : '🚴 Giao hàng tận nơi';

    // Items summary
    const itemsHtml = cart.map(item => {
        const detail = [item.option, item.size === 'LARGE' ? 'Lớn' : item.size === 'SMALL' ? 'Nhỏ' : ''].filter(Boolean).join(' · ');
        return `
            <div class="modal-info-row">
                <span class="modal-info-label">${item.name}${detail ? ` (${detail})` : ''} ×${item.qty}</span>
                <span class="modal-info-val">${formatVND(item.price * item.qty)}</span>
            </div>
        `;
    }).join('');

    const pickupTimeMap = {
        SANG_SOM: 'Sáng sớm (5:30–7:00)',
        SANG: 'Buổi sáng (7:00–9:00)',
        TRUA: 'Buổi trưa (11:00–13:00)',
        CHIEU: 'Buổi chiều (14:00–17:00)'
    };

    document.getElementById('modal-summary').innerHTML = `
        <div class="modal-info-row"><span class="modal-info-label">👤 Khách hàng</span><span class="modal-info-val">${name}</span></div>
        <div class="modal-info-row"><span class="modal-info-label">📞 Điện thoại</span><span class="modal-info-val">${phone}</span></div>
        <div class="modal-info-row"><span class="modal-info-label">📦 Hình thức</span><span class="modal-info-val">${methodLabel}</span></div>
        ${address ? `<div class="modal-info-row"><span class="modal-info-label">📍 Địa chỉ</span><span class="modal-info-val">${address}</span></div>` : ''}
        ${pickupTime ? `<div class="modal-info-row"><span class="modal-info-label">⏰ Giờ lấy</span><span class="modal-info-val">${pickupTimeMap[pickupTime] || pickupTime}</span></div>` : ''}
        ${note ? `<div class="modal-info-row"><span class="modal-info-label">📝 Ghi chú</span><span class="modal-info-val">${note}</span></div>` : ''}
        <div style="height:8px"></div>
        ${itemsHtml}
        <div class="modal-info-row"><span class="modal-info-label">Tiền hàng</span><span class="modal-info-val">${formatVND(subtotal)}</span></div>
        <div class="modal-info-row"><span class="modal-info-label">Phí ship</span><span class="modal-info-val">${shipFee > 0 ? formatVND(shipFee) : 'Miễn phí'}</span></div>
        <div class="modal-info-row"><span class="modal-info-label" style="font-weight:800">TỔNG THANH TOÁN</span><span class="modal-info-val highlight">${formatVND(total)}</span></div>
    `;

    document.getElementById('qr-amount').textContent = formatVND(total);
    
    // Set custom transfer content using customer's phone number
    const contentVal = `ANHTUBAKERY ${phone}`;
    document.getElementById('qr-content').textContent = contentVal;

    // Generate VietQR URL dynamically
    const qrImageEl = document.getElementById('qr-image');
    if (qrImageEl) {
        const qrUrl = 'https://img.vietqr.io/image/BIDV-8821037502-compact2.png'
            + '?amount=' + total
            + '&addInfo=' + encodeURIComponent(contentVal)
            + '&accountName=VO%20HO%20UYEN%20NHI';
        qrImageEl.src = qrUrl;
    }

    const overlay = document.getElementById('confirm-modal-overlay');
    overlay?.classList.remove('hidden');
    document.body.style.overflow = 'hidden';
}

function closeConfirmModal() {
    document.getElementById('confirm-modal-overlay')?.classList.add('hidden');
    document.body.style.overflow = '';
}

/* ===== PLACE ORDER ===== */
function placeOrder() {
    const btn = document.getElementById('btn-place-order');
    if (btn) { btn.disabled = true; btn.textContent = '⏳ Đang xử lý...'; }

    const cart = window.BakeryCart ? window.BakeryCart.getCart() : [];
    const subtotal = cart.reduce((s, i) => s + i.price * i.qty, 0);
    const method = document.querySelector('input[name="delivery-method"]:checked')?.value;
    const shipFee = method === 'GIAO_HANG' ? currentShippingFee : 0;
    const total = subtotal + shipFee;
    const name = document.getElementById('customer-name')?.value.trim();
    const phone = document.getElementById('customer-phone')?.value.trim();
    const address = method === 'GIAO_HANG' ? (document.getElementById('delivery-address')?.value.trim() || '') : '';
    const pickupTime = method === 'TU_LAY' ? (document.getElementById('pickup-time')?.value || '') : '';
    const note = document.getElementById('order-note')?.value.trim() || '';
    const latVal = method === 'GIAO_HANG' ? parseFloat(document.getElementById('lat')?.value) : null;
    const lngVal = method === 'GIAO_HANG' ? parseFloat(document.getElementById('lng')?.value) : null;

    // Chuẩn bị danh sách sản phẩm
    const items = cart.map(item => {
        const detail = [item.option, item.size === 'LARGE' ? 'Lớn' : item.size === 'SMALL' ? 'Nhỏ' : ''].filter(Boolean).join(' · ');
        const fullName = item.name + (detail ? ` (${detail})` : '');
        return {
            name: fullName,
            qty: item.qty,
            price: item.price
        };
    });

    const orderData = {
        customerName: name,
        customerPhone: phone,
        deliveryMethod: method,
        deliveryAddress: address,
        pickupTime: pickupTime,
        note: note,
        latitude: isNaN(latVal) ? null : latVal,
        longitude: isNaN(lngVal) ? null : lngVal,
        subtotal: subtotal,
        shippingFee: shipFee,
        total: total,
        items: items
    };

    fetch('../resources/orders', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(orderData)
    })
    .then(response => {
        if (!response.ok) {
            return response.text().then(text => { throw new Error(text || 'Đặt hàng thất bại'); });
        }
        return response.json();
    })
    .then(data => {
        closeConfirmModal();

        // Sử dụng mã đơn hàng thực tế từ backend
        const orderId = data.id;
        document.getElementById('order-id-display').textContent = orderId;

        // Cập nhật nội dung mã QR
        document.getElementById('qr-content').textContent = `ANHTUBAKERY ${orderId}`;

        // Xóa giỏ hàng
        if (window.BakeryCart) window.BakeryCart.clear();

        // Hiển thị giao diện đặt hàng thành công
        const orderLayout = document.getElementById('order-layout');
        if (orderLayout) orderLayout.style.display = 'none';
        const successPanel = document.getElementById('success-panel');
        successPanel?.classList.remove('hidden');
        successPanel?.scrollIntoView({ behavior: 'smooth' });

        if (btn) { btn.disabled = false; btn.textContent = '✅ Xác nhận đặt hàng'; }
    })
    .catch(error => {
        console.error('Error placing order:', error);
        showToast('⚠️ Lỗi: ' + error.message, 'warn');
        if (btn) { btn.disabled = false; btn.textContent = '✅ Xác nhận đặt hàng'; }
    });
}

/* ===== UTILS ===== */
if (typeof window.formatVND === 'undefined') {
    window.formatVND = function(amount) {
        return amount.toLocaleString('vi-VN') + 'đ';
    };
} else {
    // Reuse existing formatVND
    var formatVND = window.formatVND;
}

if (typeof window.showToast === 'undefined') {
    (function() {
        let localToastTimer;
        window.showToast = function(msg, type = 'success') {
            const toast = document.getElementById('toast');
            if (!toast) return;
            toast.textContent = msg;
            toast.className = 'toast show';
            toast.style.background = type === 'warn' ? '#B45309' : '#92400E';
            clearTimeout(localToastTimer);
            localToastTimer = setTimeout(() => { toast.className = 'toast'; }, 2500);
        };
    })();
} else {
    // Reuse existing showToast
    var showToast = window.showToast;
}
