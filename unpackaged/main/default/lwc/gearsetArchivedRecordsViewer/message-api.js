export const API_VERSION = "1";
export const isApiMessageEvent = (event) => !!event.data &&
    typeof event.data === "object" &&
    "type" in event.data &&
    ("endpoint" in event.data || "correlationId" in event.data);