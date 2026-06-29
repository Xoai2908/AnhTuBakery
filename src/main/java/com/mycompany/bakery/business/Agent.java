package com.mycompany.bakery.business;

public class Agent {
    private int id;
    private String name;
    private String phone;
    private String shopName;
    private String address;
    private double latitude;
    private double longitude;
    private String password;
    private String status;
    private String createdAt;

    public Agent() {}

    public Agent(int id, String name, String phone, String shopName, String address, double latitude, double longitude, String password, String status, String createdAt) {
        this.id = id;
        this.name = name;
        this.phone = phone;
        this.shopName = shopName;
        this.address = address;
        this.latitude = latitude;
        this.longitude = longitude;
        this.password = password;
        this.status = status;
        this.createdAt = createdAt;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getShopName() {
        return shopName;
    }

    public void setShopName(String shopName) {
        this.shopName = shopName;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public double getLatitude() {
        return latitude;
    }

    public void setLatitude(double latitude) {
        this.latitude = latitude;
    }

    public double getLongitude() {
        return longitude;
    }

    public void setLongitude(double longitude) {
        this.longitude = longitude;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(String createdAt) {
        this.createdAt = createdAt;
    }
}
