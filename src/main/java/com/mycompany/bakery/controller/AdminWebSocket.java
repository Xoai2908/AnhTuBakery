package com.mycompany.bakery.controller;

import jakarta.websocket.*;
import jakarta.websocket.server.ServerEndpoint;
import java.io.IOException;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.logging.Level;
import java.util.logging.Logger;

@ServerEndpoint("/admin-ws")
public class AdminWebSocket {

    private static final Logger LOGGER = Logger.getLogger(AdminWebSocket.class.getName());
    
    // Store all active admin WebSocket sessions
    private static final Set<Session> adminSessions = ConcurrentHashMap.newKeySet();

    @OnOpen
    public void onOpen(Session session) {
        adminSessions.add(session);
        LOGGER.log(Level.INFO, "Admin WebSocket connection opened. Total admins: {0}", adminSessions.size());
    }

    @OnClose
    public void onClose(Session session) {
        adminSessions.remove(session);
        LOGGER.log(Level.INFO, "Admin WebSocket connection closed. Total admins: {0}", adminSessions.size());
    }

    @OnError
    public void onError(Session session, Throwable throwable) {
        adminSessions.remove(session);
        LOGGER.log(Level.WARNING, "Admin WebSocket error: " + throwable.getMessage(), throwable);
    }

    /**
     * Broadcast a refresh signal to all connected admins to reload the dashboard.
     */
    public static void broadcastRefresh() {
        LOGGER.log(Level.INFO, "Broadcasting refresh signal to {0} admin(s)", adminSessions.size());
        for (Session session : adminSessions) {
            if (session.isOpen()) {
                try {
                    session.getBasicRemote().sendText("refresh");
                } catch (IOException e) {
                    LOGGER.log(Level.SEVERE, "Failed to send refresh signal to admin session", e);
                }
            }
        }
    }
}
