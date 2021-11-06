pragma solidity ^0.4.23;

import "./SupplyChainStorageOwnable.sol";

contract SupplyChainStorage is SupplyChainStorageOwnable {
    
    address public lastAccess;
    constructor() public {
        authorizedCaller[msg.sender] = 1;
        emit AuthorizedCaller(msg.sender);
    }
    
    /* Events */
    event AuthorizedCaller(address caller);
    event DeAuthorizedCaller(address caller);
    
    /* Modifiers */
    
    modifier onlyAuthCaller(){
        lastAccess = msg.sender;
        require(authorizedCaller[msg.sender] == 1);
        _;
    }
    
    /* User Related */
    struct user {
        string name;
        string contactNo;
        bool isActive;
        string profileHash;
    } 
    
    mapping(address => user) userDetails;
    mapping(address => string) userRole;
    
    /* Caller Mapping */
    mapping(address => uint8) authorizedCaller;
    
    /* authorize caller */
    function authorizeCaller(address _caller) public onlyOwner returns(bool) 
    {
        authorizedCaller[_caller] = 1;
        emit AuthorizedCaller(_caller);
        return true;
    }
    
    /* deauthorize caller */
    function deAuthorizeCaller(address _caller) public onlyOwner returns(bool) 
    {
        authorizedCaller[_caller] = 0;
        emit DeAuthorizedCaller(_caller);
        return true;
    }
    
    /*User Roles
        SUPER_ADMIN,
        product_INSPECTION,
        MANUFACTURER,
        EXPORTER,
        IMPORTER,
        PROCESSOR
    */
    
    /* Process Related */
     struct basicDetails {
        string registrationNo;
        string productName;
        string productAddress;
        string exporterName;
        string importerName;
        
    }
    
    struct productInspector {
        string typeOfProduct;
        string sizeDescription;
        string qualityChecked;
    }
    
    struct manufacturer {
        string rawMaterial;
        string processUsed;
        string notes;
    }    
    
    struct exporter {
        string destinationAddress;
        string shipName;
        string shipNo;
        uint256 quantity;
        uint256 departureDateTime;
        uint256 estimateDateTime;
        uint256 plantNo;
        uint256 exporterId;
    }
    
    struct importer {
        uint256 quantity;
        uint256 arrivalDateTime;
        uint256 importerId;
        string shipName;
        string shipNo;
        string transportInfo;
        string warehouseName;
        string warehouseAddress;
    }
    
    struct processor {
        uint256 quantity;
        uint256 packageDateTime;
        string internalBatchNo;
        string processorName;
        string processorAddress;
    }
    
    mapping (address => basicDetails) batchBasicDetails;
    mapping (address => productInspector) batchproductInspector;
    mapping (address => manufacturer) batchManufacturer;
    mapping (address => exporter) batchExporter;
    mapping (address => importer) batchImporter;
    mapping (address => processor) batchProcessor;
    mapping (address => string) nextAction;
    
    /*Initialize struct pointer*/
    user userDetail;
    basicDetails basicDetailsData;
    productInspector productInspectorData;
    manufacturer manufacturerData;
    exporter exporterData;
    importer importerData;
    processor processorData; 
    
    
    
    /* Get User Role */
    function getUserRole(address _userAddress) public onlyAuthCaller view returns(string)
    {
        return userRole[_userAddress];
    }
    
    /* Get Next Action  */    
    function getNextAction(address _batchNo) public onlyAuthCaller view returns(string)
    {
        return nextAction[_batchNo];
    }
        
    /*set user details*/
    function setUser(address _userAddress,
                     string _name, 
                     string _contactNo, 
                     string _role, 
                     bool _isActive,
                     string _profileHash) public onlyAuthCaller returns(bool){
        
        /*store data into struct*/
        userDetail.name = _name;
        userDetail.contactNo = _contactNo;
        userDetail.isActive = _isActive;
        userDetail.profileHash = _profileHash;
        
        /*store data into mapping*/
        userDetails[_userAddress] = userDetail;
        userRole[_userAddress] = _role;
        
        return true;
    }  
    
    /*get user details*/
    function getUser(address _userAddress) public onlyAuthCaller view returns(string name, 
                                                                    string contactNo, 
                                                                    string role,
                                                                    bool isActive, 
                                                                    string profileHash
                                                                ){

        /*Getting value from struct*/
        user memory tmpData = userDetails[_userAddress];
        
        return (tmpData.name, tmpData.contactNo, userRole[_userAddress], tmpData.isActive, tmpData.profileHash);
    }
    
    /*get batch basicDetails*/
    function getBasicDetails(address _batchNo) public onlyAuthCaller view returns(string registrationNo,
                             string productName,
                             string productAddress,
                             string exporterName,
                             string importerName) {
        
        basicDetails memory tmpData = batchBasicDetails[_batchNo];
        
        return (tmpData.registrationNo,tmpData.productName,tmpData.productAddress,tmpData.exporterName,tmpData.importerName);
    }
    
    /*set batch basicDetails*/
    function setBasicDetails(string _registrationNo,
                             string _productName,
                             string _productAddress,
                             string _exporterName,
                             string _importerName
                             
                            ) public onlyAuthCaller returns(address) {
        
        uint tmpData = uint(keccak256(msg.sender, now));
        address batchNo = address(tmpData);
        
        basicDetailsData.registrationNo = _registrationNo;
        basicDetailsData.productName = _productName;
        basicDetailsData.productAddress = _productAddress;
        basicDetailsData.exporterName = _exporterName;
        basicDetailsData.importerName = _importerName;
        
        batchBasicDetails[batchNo] = basicDetailsData;
        
        nextAction[batchNo] = 'PRODUCT_INSPECTION';   
        
        
        return batchNo;
    }
    
    /*set product Inspector data*/
    function setproductInspectorData(address batchNo,
                                    string _typeOfProduct,
                                    string _sizeDescription,
                                    string _qualityChecked) public onlyAuthCaller returns(bool){
        productInspectorData.typeOfProduct = _typeOfProduct;
        productInspectorData.sizeDescription = _sizeDescription;
        productInspectorData.qualityChecked = _qualityChecked;
        
        batchproductInspector[batchNo] = productInspectorData;
        
        nextAction[batchNo] = 'MANUFACTURER'; 
        
        return true;
    }
    
    
    /*get product inspactor data*/
    function getproductInspectorData(address batchNo) public onlyAuthCaller view returns (string typeOfProduct, string sizeDescription,string qualityChecked){
        
        productInspector memory tmpData = batchproductInspector[batchNo];
        return (tmpData.typeOfProduct, tmpData.sizeDescription, tmpData.qualityChecked);
    }
    

    /*set Manufacturer data*/
    function setManufacturerData(address batchNo,
                              string _rawMaterial,
                              string _processUsed,
                              string _notes) public onlyAuthCaller returns(bool){
        manufacturerData.rawMaterial = _rawMaterial;
        manufacturerData.processUsed = _processUsed;
        manufacturerData.notes = _notes;
        
        batchManufacturer[batchNo] = manufacturerData;
        
        nextAction[batchNo] = 'EXPORTER'; 
        
        return true;
    }
    
    /*get product manufacturer data*/
    function getManufacturerData(address batchNo) public onlyAuthCaller view returns(string rawMaterial,
                                                                                           string processUsed,
                                                                                           string notes){
        
        manufacturer memory tmpData = batchManufacturer[batchNo];
        return (tmpData.rawMaterial, tmpData.processUsed, tmpData.notes);
    }
    
    /*set Exporter data*/
    function setExporterData(address batchNo,
                              uint256 _quantity,    
                              string _destinationAddress,
                              string _shipName,
                              string _shipNo,
                              uint256 _estimateDateTime,
                              uint256 _exporterId) public onlyAuthCaller returns(bool){
        
        exporterData.quantity = _quantity;
        exporterData.destinationAddress = _destinationAddress;
        exporterData.shipName = _shipName;
        exporterData.shipNo = _shipNo;
        exporterData.departureDateTime = now;
        exporterData.estimateDateTime = _estimateDateTime;
        exporterData.exporterId = _exporterId;
        
        batchExporter[batchNo] = exporterData;
        
        nextAction[batchNo] = 'IMPORTER'; 
        
        return true;
    }
    
    /*get Exporter data*/
    function getExporterData(address batchNo) public onlyAuthCaller view returns(uint256 quantity,
                                                                string destinationAddress,
                                                                string shipName,
                                                                string shipNo,
                                                                uint256 departureDateTime,
                                                                uint256 estimateDateTime,
                                                                uint256 exporterId){
        
        
        exporter memory tmpData = batchExporter[batchNo];
        
        
        return (tmpData.quantity, 
                tmpData.destinationAddress, 
                tmpData.shipName, 
                tmpData.shipNo, 
                tmpData.departureDateTime, 
                tmpData.estimateDateTime, 
                tmpData.exporterId);
                
        
    }

    
    /*set Importer data*/
    function setImporterData(address batchNo,
                              uint256 _quantity, 
                              string _shipName,
                              string _shipNo,
                              string _transportInfo,
                              string _warehouseName,
                              string _warehouseAddress,
                              uint256 _importerId) public onlyAuthCaller returns(bool){
        
        importerData.quantity = _quantity;
        importerData.shipName = _shipName;
        importerData.shipNo = _shipNo;
        importerData.arrivalDateTime = now;
        importerData.transportInfo = _transportInfo;
        importerData.warehouseName = _warehouseName;
        importerData.warehouseAddress = _warehouseAddress;
        importerData.importerId = _importerId;
        
        batchImporter[batchNo] = importerData;
        
        nextAction[batchNo] = 'PROCESSOR'; 
        
        return true;
    }
    
    /*get Importer data*/
    function getImporterData(address batchNo) public onlyAuthCaller view returns(uint256 quantity,
                                                                                        string shipName,
                                                                                        string shipNo,
                                                                                        uint256 arrivalDateTime,
                                                                                        string transportInfo,
                                                                                        string warehouseName,
                                                                                        string warehouseAddress,
                                                                                        uint256 importerId){
        
        importer memory tmpData = batchImporter[batchNo];
        
        
        return (tmpData.quantity, 
                tmpData.shipName, 
                tmpData.shipNo, 
                tmpData.arrivalDateTime, 
                tmpData.transportInfo,
                tmpData.warehouseName,
                tmpData.warehouseAddress,
                tmpData.importerId);
                
        
    }

    /*set Proccessor data*/
    function setProcessorData(address batchNo,
                              uint256 _quantity, 
                              string _internalBatchNo,
                              uint256 _packageDateTime,
                              string _processorName,
                              string _processorAddress) public onlyAuthCaller returns(bool){
        
        
        processorData.quantity = _quantity;
        processorData.internalBatchNo = _internalBatchNo;
        processorData.packageDateTime = _packageDateTime;
        processorData.processorName = _processorName;
        processorData.processorAddress = _processorAddress;
        
        batchProcessor[batchNo] = processorData;
        
        nextAction[batchNo] = 'DONE'; 
        
        return true;
    }
    
    
    /*get Processor data*/
    function getProcessorData( address batchNo) public onlyAuthCaller view returns(
                                                                                        uint256 quantity,
                                                                                        string internalBatchNo,
                                                                                        uint256 packageDateTime,
                                                                                        string processorName,
                                                                                        string processorAddress){

        processor memory tmpData = batchProcessor[batchNo];
        
        
        return (
                tmpData.quantity, 
                tmpData.internalBatchNo,
                tmpData.packageDateTime,
                tmpData.processorName,
                tmpData.processorAddress);
                
        
    }
  
}
