pragma solidity ^0.4.23;
import "./SupplyChainStorage.sol";
import "./Ownable.sol";

contract SupplyChain is Ownable
{
  
    event Manufacture(address indexed user, address indexed batchNo);
    event DoneInspection(address indexed user, address indexed batchNo);
    event DoneProcuring(address indexed user, address indexed batchNo);
    event DoneExporting(address indexed user, address indexed batchNo);
    event DoneImporting(address indexed user, address indexed batchNo);
    event DoneProcessing(address indexed user, address indexed batchNo);

    
    /*Modifier*/
    modifier isValidPerformer(address batchNo, string role) {
    
        require(keccak256(supplyChainStorage.getUserRole(msg.sender)) == keccak256(role));
        require(keccak256(supplyChainStorage.getNextAction(batchNo)) == keccak256(role));
        _;
    }
    
    /* Storage Variables */    
    SupplyChainStorage supplyChainStorage;
    
    constructor(address _supplyChainAddress) public {
        supplyChainStorage = SupplyChainStorage(_supplyChainAddress);
    }
    
    
    /* Get Next Action  */    

    function getNextAction(address _batchNo) public view returns(string action)
    {
       (action) = supplyChainStorage.getNextAction(_batchNo);
       return (action);
    }
    

    /* get Basic Details */
    
    function getBasicDetails(address _batchNo) public view returns (string registrationNo,
                                                                     string productName,
                                                                     string productAddress,
                                                                     string exporterName,
                                                                     string importerName) {
        /* Call Storage Contract */
        (registrationNo, productName, productAddress, exporterName, importerName) = supplyChainStorage.getBasicDetails(_batchNo);  
        return (registrationNo, productName, productAddress, exporterName, importerName);
    }

    /* perform Basic Cultivation */
    
    function addBasicDetails(string _registrationNo,
                             string _productName,
                             string _productAddress,
                             string _exporterName,
                             string _importerName
                            ) public onlyOwner returns(address) {
    
        address batchNo = supplyChainStorage.setBasicDetails(_registrationNo,
                                                            _productName,
                                                            _productAddress,
                                                            _exporterName,
                                                            _importerName);
        
        emit Manufacture(msg.sender, batchNo); 
        
        return (batchNo);
    }                            
    
    /* get product Inspection */
    
    function getproductInspectorData(address _batchNo) public view returns (string memory typeOfProduct,string memory _sizeDescription, string memory qualityChecked) {
        /* Call Storage Contract */
        (typeOfProduct, _sizeDescription, qualityChecked ) = supplyChainStorage.getproductInspectorData(_batchNo);  
        return (typeOfProduct, _sizeDescription, qualityChecked);
    }
    
    /* perform product Inspection */
    
    function updateproductInspectorData(address _batchNo,
                                    string _typeOfProduct,
                                    string _sizeDescription,
                                    string _qualityChecked) 
                                public isValidPerformer(_batchNo,'PRODUCT_INSPECTION') returns(bool) {
        /* Call Storage Contract */
        bool status = supplyChainStorage.setproductInspectorData(_batchNo, _typeOfProduct, _sizeDescription, _qualityChecked);  
        
        emit DoneInspection(msg.sender, _batchNo);
        return (status);
    }

    
    /* get Product */
    
    function getManufacturerData(address _batchNo) public view returns (string rawMaterial, string processUsed, string notes) {
        /* Call Storage Contract */
        (rawMaterial, processUsed, notes) =  supplyChainStorage.getManufacturerData(_batchNo);  
        return (rawMaterial, processUsed, notes);
    }
    
    /* perform Product */
    
    function updateManufacturerData(address _batchNo,
                                string _rawMaterial,
                                string _processUsed,
                                string _notes) 
                                public isValidPerformer(_batchNo,'MANUFACTURER') returns(bool) {
                                    
        /* Call Storage Contract */
        bool status = supplyChainStorage.setManufacturerData(_batchNo, _rawMaterial, _processUsed, _notes);  
        
        emit DoneProcuring(msg.sender, _batchNo);
        return (status);
    }
    
    /* get Export */
    
    function getExporterData(address _batchNo) public view returns (uint256 quantity,
                                                                    string destinationAddress,
                                                                    string shipName,
                                                                    string shipNo,
                                                                    uint256 departureDateTime,
                                                                    uint256 estimateDateTime,
                                                                    uint256 exporterId) {
        /* Call Storage Contract */
       (quantity,
        destinationAddress,
        shipName,
        shipNo,
        departureDateTime,
        estimateDateTime,
        exporterId) =  supplyChainStorage.getExporterData(_batchNo);  
        
        return (quantity,
                destinationAddress,
                shipName,
                shipNo,
                departureDateTime,
                estimateDateTime,
                exporterId);
    }
    
    /* perform Export */
    
    function updateExporterData(address _batchNo,
                                uint256 _quantity,    
                                string _destinationAddress,
                                string _shipName,
                                string _shipNo,
                                uint256 _estimateDateTime,
                                uint256 _exporterId) 
                                public isValidPerformer(_batchNo,'EXPORTER') returns(bool) {
                                    
        /* Call Storage Contract */
        bool status = supplyChainStorage.setExporterData(_batchNo, _quantity, _destinationAddress, _shipName,_shipNo, _estimateDateTime,_exporterId);  
        
        emit DoneExporting(msg.sender, _batchNo);
        return (status);
    }
    
    /* get Import */
    
    function getImporterData(address _batchNo) public view returns (uint256 quantity,
                                                                    string shipName,
                                                                    string shipNo,
                                                                    uint256 arrivalDateTime,
                                                                    string transportInfo,
                                                                    string warehouseName,
                                                                    string warehouseAddress,
                                                                    uint256 importerId) {
        /* Call Storage Contract */
        (quantity,
         shipName,
         shipNo,
         arrivalDateTime,
         transportInfo,
         warehouseName,
         warehouseAddress,
         importerId) =  supplyChainStorage.getImporterData(_batchNo);  
         
         return (quantity,
                 shipName,
                 shipNo,
                 arrivalDateTime,
                 transportInfo,
                 warehouseName,
                 warehouseAddress,
                 importerId);
        
    }
    
    /* perform Import */
    
    function updateImporterData(address _batchNo,
                                uint256 _quantity, 
                                string _shipName,
                                string _shipNo,
                                string _transportInfo,
                                string _warehouseName,
                                string _warehouseAddress,
                                uint256 _importerId) 
                                public isValidPerformer(_batchNo,'IMPORTER') returns(bool) {
                                    
        /* Call Storage Contract */
        bool status = supplyChainStorage.setImporterData(_batchNo, _quantity, _shipName, _shipNo, _transportInfo,_warehouseName,_warehouseAddress,_importerId);  
        
        emit DoneImporting(msg.sender, _batchNo);
        return (status);
    }
    
    
    /* get Processor */
    
    function getProcessorData(address _batchNo) public view returns (uint256 quantity,
                                                                    string internalBatchNo,
                                                                    uint256 packageDateTime,
                                                                    string processorName,
                                                                    string processorAddress) {
        /* Call Storage Contract */
        (quantity,
         internalBatchNo,
         packageDateTime,
         processorName,
         processorAddress) =  supplyChainStorage.getProcessorData(_batchNo);  
         
         return (quantity,
                 internalBatchNo,
                 packageDateTime,
                 processorName,
                 processorAddress);
 
    }
    
    /* perform Processing */
    
    function updateProcessorData(address _batchNo,
                              uint256 _quantity, 
                              string _internalBatchNo,
                              uint256 _packageDateTime,
                              string _processorName,
                              string _processorAddress) public isValidPerformer(_batchNo,'PROCESSOR') returns(bool) {
                                    
        /* Call Storage Contract */
        bool status = supplyChainStorage.setProcessorData(_batchNo, 
                                                        _quantity,  
                                                        _internalBatchNo,
                                                        _packageDateTime,
                                                        _processorName,
                                                        _processorAddress);  
        
        emit DoneProcessing(msg.sender, _batchNo);
        return (status);
    }
}
