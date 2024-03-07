// codeunit 80127 "Company License Validation"
// {
//     trigger OnRun()
//     begin

//     end;

//     var
//         myInt: Integer;
//         CompanyLicenseFound: Boolean;
//         licenseCopulsary: Boolean;

//     procedure ValidateLicense(CalledFrom: Option "Sales","Purchase"; CompanyNo: code[20]; PostingGroup: Code[20]; shippingCountry: Text[30]; OrderDate: Date; ItemNo: Code[20]; PostCode: code[20])
//     var
//         ConfirmManagement: Codeunit "Confirm Management";
//         RecLicenceHeader: Record "License Header";
//         Reccomplicensheader: Record "Company License Header";
//         RecLicenseLine: Record "License Line";
//         ReccomplicensLine: Record "Company License Line";
//         RecItemAttValMap: Record "Item Attribute Value Mapping";
//         RecItem: Record Item;
//         FinalPostingCode: Code[20];
//         FindCategory: Code[20];
//         CheckValidation: Boolean;
//         AttributeValue: Text[500];
//         ItemAttributeValue: Record "Item Attribute Value";
//         ItemAttribute: Record "Item Attribute";
//     begin
//         RecItem.Reset();
//         RecItem.SetRange("No.", ItemNo);
//         if RecItem.FindFirst() then;

//         // To get attibute details
//         RecItemAttValMap.Reset();
//         RecItemAttValMap.SetRange("Table ID", 27);
//         RecItemAttValMap.SetRange("No.", ItemNo);
//         if RecItemAttValMap.FindSet() then begin
//             repeat
//                 //New Code Added 09/26/2021+++
//                 Clear(AttributeValue);
//                 ItemAttribute.Reset();
//                 ItemAttribute.SetRange(ID, RecItemAttValMap."Item Attribute ID");
//                 if ItemAttribute.FindFirst() then begin
//                     ItemAttributeValue.SetRange("Attribute ID", ItemAttribute.ID);
//                     ItemAttributeValue.SetRange(ID, RecItemAttValMap."Item Attribute Value ID");
//                     if ItemAttributeValue.FindFirst() then begin
//                         AttributeValue := ItemAttributeValue.Value;
//                     end;
//                 end;


//                 Clear(CompanyLicenseFound);
//                 Clear(licenseCopulsary);
//                 RecLicenseLine.CalcFields(Status);
//                 //RecLicenseLine.SetCurrentKey("Warning Type");
//                 RecLicenseLine.Reset();
//                 //RecLicenseLine.SetRange("Item Category", RecItem."Item Category Code"); //Commented By Abdul++
//                 RecLicenseLine.SetRange("Item Attribute ID", RecItemAttValMap."Item Attribute ID");
//                 RecLicenseLine.SetRange("Item Attribute Value ID", RecItemAttValMap."Item Attribute Value ID");
//                 RecLicenseLine.SetRange(Status, RecLicenseLine.Status::Release);
//                 RecLicenseLine.SetRange(Mandatory, true);
//                 //RecLicenseLine.SetAscending("Warning Type", false);
//                 if RecLicenseLine.FindSet() then begin
//                     repeat
//                         Clear(FindCategory);
//                         CheckValidation := false;
//                         RecLicenseLine.CalcFields("Apply to Child Categories");
//                         if RecLicenseLine."Apply to Child Categories" = true then begin
//                             if RecLicenseLine."Item Category" = RecItem."Item Category Code" then begin
//                                 FindCategory := RecLicenseLine."Item Category";
//                                 CheckValidation := true;
//                             end else begin
//                                 if RecLicenseLine."Item Category" = FindParentCategory(RecItem."Item Category Code") then begin
//                                     FindCategory := RecLicenseLine."Item Category";
//                                     CheckValidation := true;
//                                 end;
//                             end;
//                         end else begin
//                             if RecLicenseLine."Item Category" = RecItem."Item Category Code" then begin
//                                 FindCategory := RecLicenseLine."Item Category";
//                                 CheckValidation := true;
//                             end;
//                         end;

//                         if CheckValidation = true then begin
//                             RecLicenseLine.CalcFields("Warning Text", "Warning Type", "Apply To", "Supplier Posting Group", "Customer Posting Group", Country, "Country Validation");
//                             /*
//                                                 //posting group if sale order
//                                                 Clear(FinalPostingCode);
//                                                 if CalledFrom = 0 then begin
//                                                     FinalPostingCode := RecLicenseLine."Customer Posting Group"
//                                                 end else begin
//                                                     //posting group if Purchase order
//                                                     FinalPostingCode := RecLicenseLine."Supplier Posting Group";
//                                                 end;
//                             */
//                             if CalledFrom = CalledFrom::Purchase then begin
//                                 If RecLicenseLine."Country Validation" = RecLicenseLine."Country Validation"::" " then begin
//                                     if (RecLicenseLine."Customer Posting Group" = PostingGroup) and (RecLicenseLine.Country = shippingCountry) then begin
//                                         if (RecLicenseLine."Apply To" = RecLicenseLine."Apply To"::Both) or (RecLicenseLine."Apply To" = RecLicenseLine."Apply To"::Purchase) then begin
//                                             licenseCopulsary := true;
//                                             //ValidateCompanyLicense(CalledFrom, CompanyNo, RecItem."Item Category Code", RecItemAttValMap."Item Attribute ID", RecItemAttValMap."Item Attribute Value ID", RecLicenseLine."License Code", PostingGroup, shippingCountry, OrderDate, true, PostCode);
//                                             ValidateCompanyLicense(CalledFrom, CompanyNo, FindCategory, RecItemAttValMap."Item Attribute ID", RecItemAttValMap."Item Attribute Value ID", RecLicenseLine."License Code", PostingGroup, shippingCountry, OrderDate, true, PostCode, ItemNo, AttributeValue);
//                                         end;
//                                     end;
//                                 end Else Begin
//                                     if (RecLicenseLine."Customer Posting Group" = PostingGroup) then begin
//                                         if (RecLicenseLine."Apply To" = RecLicenseLine."Apply To"::Both) or (RecLicenseLine."Apply To" = RecLicenseLine."Apply To"::Purchase) then begin
//                                             licenseCopulsary := true;
//                                             //ValidateCompanyLicense(CalledFrom, CompanyNo, RecItem."Item Category Code", RecItemAttValMap."Item Attribute ID", RecItemAttValMap."Item Attribute Value ID", RecLicenseLine."License Code", PostingGroup, shippingCountry, OrderDate, false, PostCode);
//                                             ValidateCompanyLicense(CalledFrom, CompanyNo, FindCategory, RecItemAttValMap."Item Attribute ID", RecItemAttValMap."Item Attribute Value ID", RecLicenseLine."License Code", PostingGroup, shippingCountry, OrderDate, false, PostCode, ItemNo, AttributeValue);
//                                         end;
//                                     end;
//                                 End;
//                             end else begin
//                                 If RecLicenseLine."Country Validation" = RecLicenseLine."Country Validation"::" " then begin
//                                     if (RecLicenseLine."Customer Posting Group" = PostingGroup) and (RecLicenseLine.Country = shippingCountry) then begin
//                                         if (RecLicenseLine."Apply To" = RecLicenseLine."Apply To"::Both) or (RecLicenseLine."Apply To" = RecLicenseLine."Apply To"::Sales) then begin
//                                             licenseCopulsary := true;
//                                             //ValidateCompanyLicense(CalledFrom, CompanyNo, RecItem."Item Category Code", RecItemAttValMap."Item Attribute ID", RecItemAttValMap."Item Attribute Value ID", RecLicenseLine."License Code", PostingGroup, shippingCountry, OrderDate, true, PostCode);
//                                             ValidateCompanyLicense(CalledFrom, CompanyNo, FindCategory, RecItemAttValMap."Item Attribute ID", RecItemAttValMap."Item Attribute Value ID", RecLicenseLine."License Code", PostingGroup, shippingCountry, OrderDate, true, PostCode, ItemNo, AttributeValue);
//                                         end;
//                                     end;
//                                 end Else Begin
//                                     if (RecLicenseLine."Customer Posting Group" = PostingGroup) then begin
//                                         if (RecLicenseLine."Apply To" = RecLicenseLine."Apply To"::Both) or (RecLicenseLine."Apply To" = RecLicenseLine."Apply To"::Sales) then begin
//                                             licenseCopulsary := true;
//                                             //ValidateCompanyLicense(CalledFrom, CompanyNo, RecItem."Item Category Code", RecItemAttValMap."Item Attribute ID", RecItemAttValMap."Item Attribute Value ID", RecLicenseLine."License Code", PostingGroup, shippingCountry, OrderDate, false, PostCode);
//                                             ValidateCompanyLicense(CalledFrom, CompanyNo, FindCategory, RecItemAttValMap."Item Attribute ID", RecItemAttValMap."Item Attribute Value ID", RecLicenseLine."License Code", PostingGroup, shippingCountry, OrderDate, false, PostCode, ItemNo, AttributeValue);
//                                         end;
//                                     end;
//                                 End;
//                             end;
//                         end;
//                     until RecLicenseLine.Next = 0;
//                 end;
//             until RecItemAttValMap.Next = 0;
//         end;
//     end;


//     local procedure FindParentCategory(ChildCategory: Code[20]): code[20]
//     var
//         L_ItemCategory: Record "Item Category";
//         CategoryCode: Code[20];
//         Loop_ParentCategoryCode: Code[20];
//     begin
//         //The below code is only for SIGMA Process++
//         //Check the first Parent category code of Child Category++
//         Clear(Loop_ParentCategoryCode);
//         Clear(CategoryCode);
//         L_ItemCategory.Reset();
//         L_ItemCategory.SetRange(Code, ChildCategory);
//         if L_ItemCategory.FindFirst() then begin
//             Loop_ParentCategoryCode := L_ItemCategory."Parent Category";
//             CategoryCode := L_ItemCategory."Parent Category";
//         end;

//         //Find the last parent category Code++
//         repeat
//             L_ItemCategory.Reset();
//             if L_ItemCategory.Get(Loop_ParentCategoryCode) then begin
//                 Loop_ParentCategoryCode := L_ItemCategory."Parent Category";
//                 if L_ItemCategory."Parent Category" <> '' then
//                     CategoryCode := L_ItemCategory."Parent Category";
//             end else
//                 Loop_ParentCategoryCode := '';
//         until Loop_ParentCategoryCode = '';
//         exit(CategoryCode);
//     end;


//     local procedure ValidateCompanyLicense(CalledFrom: Option "Sales","Purchase"; CompanyNo: code[20]; ItemCatCode: Code[20]; ItemAttrId: Integer; ItemAttrValueId: Integer; LicenseCode: Code[100]; PostingGroup: Code[20]; shippingCountry: Text[30]; OrderDate: Date; countryvalidation: Boolean; PostCode: code[20]; ItemCode: Code[20]; AttributeValue: Text[500])
//     var
//         ReccomplicensLine: Record "Company License Line";
//         RecLicenseLine: Record "License Line";
//         ConfirmManagement: Codeunit "Confirm Management";
//     begin
//         ReccomplicensLine.Reset();
//         ReccomplicensLine.SetRange("Company No.", CompanyNo);
//         ReccomplicensLine.SetRange("Item Category", ItemCatCode);
//         ReccomplicensLine.SetRange("Item Attribute ID", ItemAttrId);
//         ReccomplicensLine.SetRange("Item Attribute Value ID", ItemAttrValueId);
//         //ReccomplicensLine.SetRange("License Code", LicenseCode);
//         ReccomplicensLine.SetRange("Posting Group", PostingGroup);
//         ReccomplicensLine.CalcFields("Post code");
//         if PostCode <> '' then
//             ReccomplicensLine.SetRange("Post code", PostCode);
//         if countryvalidation then
//             ReccomplicensLine.SetRange("Shipping Country", shippingCountry);
//         //ReccomplicensLine.SetRange(Mandatory, true);25 feb
//         if ReccomplicensLine.FindFirst() then begin
//             ReccomplicensLine.CalcFields(Status, "Grant Date", "Expiry Date", "Post code");
//             ReccomplicensLine.CalcFields("Post code");
//             if ReccomplicensLine."Post code" = PostCode then begin
//                 if ReccomplicensLine.Status = ReccomplicensLine.Status::Release then begin
//                     if (ReccomplicensLine."Grant Date" <= OrderDate) and (ReccomplicensLine."Expiry Date" >= OrderDate) then begin
//                         CompanyLicenseFound := true;
//                     end else begin
//                         //Error('Valid Licence Not Found');
//                     end;
//                 end else begin
//                     //Error('Valid Licence Not Found');
//                 end;
//             end else begin
//                 //Error('Valid Licence Not Found');
//             end;
//         end else begin
//             //Error('Valid Licence Not Found');
//         end;

//         //New Code Added 09262021+++
//         if CompanyLicenseFound = false then begin
//             RecLicenseLine.Reset();
//             RecLicenseLine.SetRange("License Code", LicenseCode);
//             if RecLicenseLine.FindFirst() then begin
//                 RecLicenseLine.CalcFields("Warning Text", "Warning Type");
//                 if RecLicenseLine."Warning Type" = RecLicenseLine."Warning Type"::Error then begin
//                     Error('%1 for Item No.: %2 and Item Attribute: %3', RecLicenseLine."Warning Text", ItemCode, AttributeValue);
//                 end;
//                 if RecLicenseLine."Warning Type" = RecLicenseLine."Warning Type"::Warning then begin
//                     if not ConfirmManagement.GetResponseOrDefault(StrSubstNo('%1 for Item No.: %2 and Item Attribute: %3', RecLicenseLine."Warning Text", ItemCode, AttributeValue), true) then begin
//                         Error('Process Stopped Please Revert Changes');
//                     end else begin
//                     end;
//                 end;
//                 if RecLicenseLine."Warning Type" = RecLicenseLine."Warning Type"::" " then
//                     Error('License setup manadatory found and valid customer licence not found');
//             end;
//         end;
//         //New Code Added 09262021+++

//     end;
// }