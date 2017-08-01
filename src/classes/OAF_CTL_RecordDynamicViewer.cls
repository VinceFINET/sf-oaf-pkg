/**
 * @author Vincent FINET
 * @description Custom controller for OAF_VFP_RecordDynamicViewer visual force page
 **/
public with sharing class OAF_CTL_RecordDynamicViewer {
	
    public Id id { public get; private set; }
    public String objectName { public get; private set; }
    public List<Schema.DescribeFieldResult> fieldsDescribes { public get; private set; }
    public String query { public get; private set; }
	public Map<String, Object> values { public get; private set; }
        
    public OAF_CTL_RecordDynamicViewer() {
        
        String id = ApexPages.currentPage().getParameters().get('id');        
        if (id == null) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR, 
                'You must specify an Id in the URL of this page.'));
            return;
        }

        String idType = id.subString(0,3);
        String objectName = null;
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        for (Schema.SObjectType objtype : gd.values()) if (objtype.getDescribe().getKeyPrefix() == idType) {
            objectName = objtype.getDescribe().getName();
            continue;
        }
        if (objectName == null) {
	        ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR, 
                'Did not find the object type of given Id in this org.'));
            return;
        }
        
        List<Schema.DescribeFieldResult> fieldsDescribes = new List<Schema.DescribeFieldResult>();
        Map<String, Schema.sObjectField> fields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        String fieldsName = '';
        for (String fieldKey : fields.keySet()) {
            Schema.DescribeFieldResult dfr = fields.get(fieldKey).getDescribe();
            fieldsDescribes.add(dfr);
            fieldsName += dfr.getName() + ', ';
        }
        String query = 
            'SELECT '+fieldsName.substringBeforeLast(',')+' '+
            'FROM '+objectName+' '+
            'WHERE Id=:id '+
            'LIMIT 1';
        SObject obj = Database.query(query);
        Map<String, Object> values = new Map<String, Object>();
        for (Schema.DescribeFieldResult dfr : fieldsDescribes) {
            String key = dfr.getName();
            if (dfr.getType().name() == 'ADDRESS') {
                values.put(key, 'N/A');
            } else {
                Object value = obj.get(dfr.getName());
                values.put(key, value == null ? '' : value);
            }
        }
        
        this.id = id;
        this.objectName = objectName;
        this.fieldsDescribes = fieldsDescribes;
        this.query = query.replace(':id', '\''+id+'\'');
        this.values = values;
    }
}
