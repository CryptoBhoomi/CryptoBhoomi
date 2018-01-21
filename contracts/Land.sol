pragma solidity ^0.4.2;


contract Land {
    address public propertyOwner;
    string public ownerName;

    mapping(uint => string) reportTrail;
    mapping(uint => string) problemReportTrail;
    uint8 ReportTrailCount = 0;
    uint8 ProblemReportTrailCount = 0;

    function Land() public {
        propertyOwner = msg.sender;
    }

    LandState public state;

    struct Property {
    string ownerName;
    string addressStr;
    string propertyId;
    address buyer;
    string buyerName;
    address registrar;
    address revenueDept;
    address legalDept;
    address forestDept;
    address bank;
    string amountStr;
    }

    uint8 TrailCount = 0;

    function AddProperty(
    string ownerName,
    string addressStr,
    string propertyId,
    address buyer,
    string buyerName,
    address registrar,
    address revenueDept,
    address legalDept,
    address forestDept,
    address bank,
    string amountStr){
        Property memory property;
        property.ownerName = ownerName;
        property.addressStr = addressStr;
        property.propertyId = propertyId;
        property.buyer = buyer;
        property.buyerName = buyerName;
        property.registrar = registrar;
        property.revenueDept = revenueDept;
        property.legalDept = legalDept;
        property.forestDept = forestDept;
        property.bank = bank;
        property.amountStr = amountStr;
        LandTrail[TrailCount] = property;
        state = LandState.Default;
        TrailCount++;
    }

    mapping (uint => Property) LandTrail;

    event Report(string actor, string remark, uint Timestamp, address actorAddress);

    event ProblemReport(string actor, string remark, uint Timestamp, address actorAddress);

    enum LandState {Default, SaleInitiated, BuyerSaleAgreed, SellerSaleAgreed, RegistrarSaleApprove, ConfirmPayment}

    function LatestTrailCount() returns (uint8){
        return TrailCount;
    }

    function InitiateSale(){
        if (msg.sender == propertyOwner && state == LandState.Default) {
            state = LandState.SaleInitiated;
            reportTrail[ReportTrailCount]= "Sale Initiated";
            ReportTrailCount++;
            Report("Owner", "Sale Initiated", now, msg.sender);
        }
        else {
            throw;
        }
    }

    function BuyerAgreeSale(){
        if (msg.sender == LandTrail[TrailCount - 1].buyer && state == LandState.SaleInitiated) {
            state = LandState.BuyerSaleAgreed;
            reportTrail[ReportTrailCount]= "Buyer Sale Agreed";
            ReportTrailCount++;
            Report("Buyer", "Sale Agreed", now, msg.sender);
        }
        else {
            throw;
        }
    }

    function SellerAgreeSale(){
        if (msg.sender == propertyOwner && state == LandState.BuyerSaleAgreed) {
            state = LandState.SellerSaleAgreed;
            reportTrail[ReportTrailCount]= "Seller Sale Agreed";
            ReportTrailCount++;
            Report("Seller", "Sale Agreed", now, msg.sender);
        }
        else {
            throw;
        }
    }

    function RegistrarSaleApproval(string amountStr){
        if (msg.sender == LandTrail[TrailCount - 1].registrar && state == LandState.SellerSaleAgreed) {
            state = LandState.RegistrarSaleApprove;
            Property memory property = LandTrail[TrailCount - 1];
            property.amountStr = amountStr;
            LandTrail[TrailCount] = property;
            reportTrail[ReportTrailCount]= "Registrar Sale Approve";
            ReportTrailCount++;
            Report("Registrar", "Registrar Sale Approve", now, msg.sender);
        }
        else {
            throw;
        }
    }

    function ConfirmPayment(){
        if (msg.sender == LandTrail[TrailCount - 1].buyer && state == LandState.RegistrarSaleApprove) {
            state = LandState.ConfirmPayment;
            reportTrail[ReportTrailCount]= "Buyer Confirm Payment";
            ReportTrailCount++;
            Report("Buyer", "Confirm Payment", now, msg.sender);
        }
        else {
            throw;
        }
    }

    function TransferDeed(){
        if (msg.sender == LandTrail[TrailCount - 1].registrar && state == LandState.ConfirmPayment) {
            propertyOwner = LandTrail[TrailCount - 1].buyer;
            ownerName = LandTrail[TrailCount - 1].buyerName;
            Property memory property = LandTrail[TrailCount - 1];
            property.buyer = 0;
            property.buyerName = "";
            LandTrail[TrailCount] = property;
            TrailCount++;
            state = LandState.Default;
            reportTrail[ReportTrailCount]= "Registrar Transferred Deed";
            ReportTrailCount++;
            Report("Registrar", "Registrar Transferred Deed", now, msg.sender);
        }
        else {
            throw;
        }
    }

    function reportPropertyDiscrepancy(string department, string remark){
        if (msg.sender == LandTrail[TrailCount - 1].revenueDept ||
        msg.sender == LandTrail[TrailCount - 1].legalDept ||
        msg.sender == LandTrail[TrailCount - 1].forestDept ||
        msg.sender == LandTrail[TrailCount - 1].bank) {
            reportTrail[ReportTrailCount]= remark;
            ReportTrailCount++;
            problemReportTrail[ProblemReportTrailCount]= remark;
            ProblemReportTrailCount++;
            Report(department, remark, now, msg.sender);
            ProblemReport(department, remark, now, msg.sender);
        }
    }

    function GetProperty(uint8 TrailNo) returns (string,string,string,string,string){
        return (
        LandTrail[TrailNo-1].ownerName,
        LandTrail[TrailNo-1].addressStr,
        LandTrail[TrailNo-1].propertyId,
        LandTrail[TrailNo-1].buyerName,
        LandTrail[TrailNo-1].amountStr
        );
    }

    function GetPropertyDetails() returns (string,string,string,string,string){
        return (
        LandTrail[TrailCount-1].ownerName,
        LandTrail[TrailCount-1].addressStr,
        LandTrail[TrailCount-1].propertyId,
        LandTrail[TrailCount-1].buyerName,
        LandTrail[TrailCount-1].amountStr
        );
    }

    function GetReport(uint8 TrailNo) returns (string){
        return reportTrail[TrailNo-1];
    }

    function GetReportTrail(uint8 TrailNo) returns (string){
        return reportTrail[TrailNo-1];
    }

    function LatestReportTrailCount() returns (uint8){
        return ReportTrailCount;
    }

    function GetProblemReport(uint8 TrailNo) returns (string){
        return problemReportTrail[TrailNo-1];
    }

    function LatestProblemReportTrailCount() returns (uint8){
        return ProblemReportTrailCount;
    }

    function GetOwner() returns (string,address){
        return (ownerName,propertyOwner);
    }
}