package com.mycompany.bakery.controller;

import jakarta.websocket.*;
import jakarta.websocket.server.PathParam;
import jakarta.websocket.server.ServerEndpoint;
import java.io.IOException;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.logging.Level;
import java.util.logging.Logger;

@ServerEndpoint("/order-ws/{orderId}")
public class OrderWebSocket {

    private static final Logger LOGGER = Logger.getLogger(OrderWebSocket.class.getName());
    
    // Maps Order IDs to their corresponding active WebSocket sessions (handles multiple tabs/devices)
    private static final Map<String, Set<Session>> orderSessions = new ConcurrentHashMap<>();

    @OnOpen
    public void onOpen(Session session, @PathParam("orderId") String orderId) {
        if (orderId != null && !orderId.trim().isEmpty()) {
            String cleanId = orderId.trim();
            orderSessions.computeIfAbsent(cleanId, k -> ConcurrentHashMap.newKeySet()).add(session);
            LOGGER.log(Level.INFO, "WebSocket opened for order: {0}. Total active tabs: {1}", 
                    new Object[]{cleanId, orderSessions.get(cleanId).size()});
        }
    }

    @OnClose
    public void onClose(Session session, @PathParam("orderId") String orderId) {
        if (orderId != null) {
            String cleanId = orderId.trim();
            Set<Session> sessions = orderSessions.get(cleanId);
            if (sessions != null) {
                sessions.remove(session);
                if (sessions.isEmpty()) {
                    orderSessions.remove(cleanId);
                }
            }
            LOGGER.log(Level.INFO, "WebSocket closed for order: {0}", cleanId);
        }
    }

    @OnError
    public void onError(Session session, Throwable throwable, @PathParam("orderId") String orderId) {
        if (orderId != null) {
            String cleanId = orderId.trim();
            Set<Session> sessions = orderSessions.get(cleanId);
            if (sessions != null) {
                sessions.remove(session);
                if (sessions.isEmpty()) {
                    orderSessions.remove(cleanId);
                }
            }
            LOGGER.log(Level.WARNING, "WebSocket error for order " + cleanId + ": " + throwable.getMessage(), throwable);
        }
    }

    /**
     * Sends a status update message to all connected clients/tabs for the given order ID.
     *
     * @param orderId the order identifier
     * @param status the new order status
     */
    public static void sendStatusUpdate(String orderId, String status) {
        if (orderId == null || status == null) {
            return;
        }
        String cleanId = orderId.trim();
        Set<Session> sessions = orderSessions.get(cleanId);
        if (sessions != null && !sessions.isEmpty()) {
            LOGGER.log(Level.INFO, "Broadcasting status update ''{0}'' for order: {1} to {2} client(s)", 
                    new Object[]{status, cleanId, sessions.size()});
            for (Session session : sessions) {
                if (session.isOpen()) {
                    try {
                        session.getBasicRemote().sendText(status);
                    } catch (IOException e) {
                        LOGGER.log(Level.SEVERE, "Failed to send status update to connection for order: " + cleanId, e);
                    }
                }
            }
        }
    }
}
