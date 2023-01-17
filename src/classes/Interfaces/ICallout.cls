public interface ICallout {
    ICallout setEndpoint(String endpoint);
    HttpResponse get();
}