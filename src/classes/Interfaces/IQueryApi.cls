public interface IQueryApi {
//    IQueryApi setLimitCount(Integer limitCount);
    List<SObject> getRecordsByObjectNameAndQuery(String objectName, String customQuery);
    List<SObject> getRecordsByObjectName(String objectName,Integer limitCount);
}