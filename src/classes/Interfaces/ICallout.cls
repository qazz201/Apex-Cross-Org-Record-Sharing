public interface ICallout {
    ICallout setEndpoint(String endpoint);
    CalloutClient setHeader(String key, String value);
    CalloutClient setHeaders(Map<String, String> headers);
    HttpResponse get();
    HttpResponse post();
    HttpResponse post(Object body);
}