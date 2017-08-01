List<String> objects = new List<String>();
for (Schema.SObjectType objectType : Schema.getGlobalDescribe().values()) {
    String objName = String.valueOf(objectType);
    if (!objName.contains('__')) {
                objects.add(objName);
    }
}
 
String output = '';
 
output += '\t<types>\n';
output += '\t\t<name>CustomObject</name>\n';
for (String objName : objects) {
    output += '\t\t<members>'+objName+'</members>\n';
}
output += '\t</types>\n';
 
output += '\t<types>\n';
output += '\t\t<name>CustomFields</name>\n';
for (String objName : objects) {
            Map<String, Schema.SObjectField> fields = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap();
    for (String fieldName : fields.keySet()) {
        if (!fieldName.contains('__')) {
                            output += '\t\t<members>'+objName+'.'+fieldName+'</members>\n';
        }
    }
}
output += '\t</types>\n';
 
insert new Document(
            FolderId = UserInfo.getUserId(),
    Name = 'Package.xml',
    ContentType = 'text/plain',
    Body = Blob.valueOf(output),
    Type = 'txt'
);
