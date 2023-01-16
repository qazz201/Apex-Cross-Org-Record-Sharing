public interface ICalloutClient {
    ICalloutClient setEndpoint(String endpoint);
    HttpResponse get();
}