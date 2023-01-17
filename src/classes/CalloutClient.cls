public with sharing class CalloutClient implements ICallout {
    private HttpRequest request = new HttpRequest();
    private Map<String, String> headers = new Map<String, String>();
    private String endpoint;

    public CalloutClient() {
    }

    public CalloutClient(String endpoint) {
        this.endpoint = endpoint;
    }

    public CalloutClient setEndpoint(String endpoint) {
        this.endpoint = endpoint;
        return this;
    }

    public CalloutClient setHeader(String key, String value) {
        this.setHeaders(new Map<String, String>{
                key => value
        });
        return this;
    }

    public CalloutClient setHeaders(Map<String, String> headers) {
        this.headers.putAll(headers);
        return this;
    }

    public HTTPResponse get() {
        return this.execute('GET', null);
    }

    private HTTPResponse execute(String method, Object body) {
        this.request.setEndpoint(endpoint);
        this.request.setMethod(method);
        this.setHeaders();

        if (body != null) {
            this.setRequestBody(body);
        }
        try {
            HttpResponse response = new Http().send(request);
            if (response.getStatusCode() != 200) {
                String errorMessage = '### Unexpected Error while call external resource '
                        + 'Status ' + response.getStatus() + ' and Status Code ' + response.getStatusCode();

                System.debug(errorMessage + response.getBody());
            }

            return response;
        } catch (System.Exception e) {
            System.debug('#### Exception Executed ' + e.getStackTraceString() + '  ' + e.getMessage());
        }

        return null;
    }

    private void setHeaders() {
        for (String headerName : this.headers.keySet()) {
            this.request.setHeader(headerName, this.headers.get(headerName));
        }
    }

    private void setRequestBody(Object body) {
        if (body == null) return;

        if (body instanceOf Blob) {
            this.request.setBodyAsBlob((Blob) body);
        } else if (body instanceOf String) {
            this.request.setBody((String) body);
        } else {
            this.request.setBody(Json.serialize(body));
        }
    }
}