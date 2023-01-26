public interface ICallout {
    ICallout setEndpoint(String endpoint);
    String getEndpoint();
    CalloutClient clearAllHeaders();
    CalloutClient setHeader(String key, String value);
    CalloutClient setHeaders(Map<String, String> headers);
    HttpResponse get();
    HttpResponse post();
    HttpResponse post(Object body);
}