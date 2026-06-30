package com.mycompany.bakery.controller;

import com.mycompany.bakery.business.Order;
import com.mycompany.bakery.business.OrderService;
import jakarta.inject.Inject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.json.Json;
import jakarta.json.JsonObject;
import jakarta.json.JsonReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.StringReader;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

@WebServlet(name = "PaymentWebhookServlet", urlPatterns = {"/payment-webhook"})
public class PaymentWebhookServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(PaymentWebhookServlet.class.getName());
    private static final Pattern ORDER_ID_PATTERN = Pattern.compile("DH\\d+", Pattern.CASE_INSENSITIVE);
    
    private String webhookToken;

    @Inject
    private OrderService orderService;

    @Override
    public void init() throws ServletException {
        super.init();
        loadWebhookToken();
    }

    private void loadWebhookToken() {
        try (InputStream input = PaymentWebhookServlet.class.getClassLoader().getResourceAsStream("db.properties")) {
            if (input != null) {
                Properties prop = new Properties();
                prop.load(input);
                webhookToken = prop.getProperty("payment.sepay.token", "sepay_secret_token_123").trim();
                LOGGER.info("Loaded payment webhook token from db.properties");
            } else {
                webhookToken = "sepay_secret_token_123";
                LOGGER.warning("db.properties not found. Using default webhook token.");
            }
        } catch (Exception e) {
            webhookToken = "sepay_secret_token_123";
            LOGGER.log(Level.SEVERE, "Error loading webhook token: " + e.getMessage(), e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        
        // 1. Verify Authorization Token
        String authHeader = request.getHeader("Authorization");
        if (authHeader == null || !authHeader.startsWith("Apikey ")) {
            LOGGER.warning("Unauthorized webhook request: Missing or invalid Authorization header");
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().print("{\"error\":\"Unauthorized: Missing or invalid token\"}");
            return;
        }

        String token = authHeader.substring(7).trim();
        if (!webhookToken.equals(token)) {
            LOGGER.warning("Unauthorized webhook request: Token mismatch");
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().print("{\"error\":\"Unauthorized: Token mismatch\"}");
            return;
        }

        // 2. Read Request Body
        String requestBody = request.getReader().lines().collect(Collectors.joining(System.lineSeparator()));
        LOGGER.info("Received payment webhook: " + requestBody);

        try (JsonReader jsonReader = Json.createReader(new StringReader(requestBody))) {
            JsonObject jsonObject = jsonReader.readObject();
            
            // SePay payload structure checking
            String transactionContent = "";
            if (jsonObject.containsKey("content")) {
                transactionContent = jsonObject.getString("content");
            } else if (jsonObject.containsKey("description")) {
                transactionContent = jsonObject.getString("description");
            } else if (jsonObject.containsKey("addInfo")) {
                transactionContent = jsonObject.getString("addInfo");
            }
            
            if (transactionContent == null || transactionContent.trim().isEmpty()) {
                LOGGER.warning("Transaction content is empty");
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().print("{\"error\":\"Invalid payload: Missing transaction description\"}");
                return;
            }

            // 3. Extract Order ID (DH\d+)
            Matcher matcher = ORDER_ID_PATTERN.matcher(transactionContent);
            if (matcher.find()) {
                String orderId = matcher.group().toUpperCase();
                LOGGER.info("Extracted Order ID from transaction content: " + orderId);

                // 4. Update order status to PAID
                Order order = orderService.getOrderById(orderId);
                if (order != null) {
                    if ("PENDING".equals(order.getStatus())) {
                        boolean updated = orderService.updateOrderStatus(orderId, "PAID");
                        if (updated) {
                            LOGGER.info("Successfully updated order " + orderId + " to PAID");
                            
                            // Send websocket update to customer tracking page
                            OrderWebSocket.sendStatusUpdate(orderId, "PAID");
                            
                            // Send websocket update to admin dashboard to reload
                            AdminWebSocket.broadcastRefresh();
                            
                            response.setStatus(HttpServletResponse.SC_OK);
                            response.getWriter().print("{\"success\":true,\"message\":\"Order updated to PAID\"}");
                            return;
                        } else {
                            LOGGER.warning("Failed to update status for order " + orderId);
                            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                            response.getWriter().print("{\"error\":\"Database update failed\"}");
                            return;
                        }
                    } else {
                        LOGGER.info("Order " + orderId + " is already in status: " + order.getStatus());
                        response.setStatus(HttpServletResponse.SC_OK);
                        response.getWriter().print("{\"success\":true,\"message\":\"Order already updated\"}");
                        return;
                    }
                } else {
                    LOGGER.warning("Order not found: " + orderId);
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    response.getWriter().print("{\"error\":\"Order not found\"}");
                    return;
                }
            } else {
                LOGGER.warning("Could not extract any Order ID (DH...) from content: " + transactionContent);
                response.setStatus(HttpServletResponse.SC_OK);
                response.getWriter().print("{\"success\":false,\"message\":\"No matching Order ID found in transfer content\"}");
            }

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error processing payment webhook", e);
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().print("{\"error\":\"Invalid JSON format or processing error: " + e.getMessage() + "\"}");
        }
    }
}
