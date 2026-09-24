package vn.edu.fpt.motelbackend.enums;

public enum RoomStatus {
    AVAILABLE, OCCUPIED, MAINTENANCE, RESERVED;

    public static RoomStatus toRoomStatus(String status) {
        switch (status.toUpperCase()) {
            case "AVAILABLE":
                return AVAILABLE;
            case "OCCUPIED":
                return OCCUPIED;
            case "MAINTENANCE":
                return MAINTENANCE;
            case "RESERVED":
                return RESERVED;
            default:
                throw new IllegalArgumentException("Invalid room status: " + status);
        }
    }
}
