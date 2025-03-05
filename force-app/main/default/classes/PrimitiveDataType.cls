public with sharing class PrimitiveDataType {
    String name = 'sravi';
    public PrimitiveDataType() {
    }
    public void exampleString(){
        name = name.capitalize();
        System.debug('My name after capitalised::'+ name);
    }
    public void variablePasser(){
        String ValueString = 'Howdy';
        Contact conRef = new Contact();
        passMyVariable(ValueString, conRef);
        System.debug('This is the string after we pass it through the original method::' + ValueString);
        System.debug('This is the conact after we pass it through original method::' + conRef);
    }

    public void passMyVariable(String passByValue, Contact passByReference){
        passByValue = 'Hello! How are you doing?';
        passByReference.LastName = 'Cheerladinne';
        passByReference.FirstName = 'Sravanthi';
    }
    
}