page 50138 "Item Journal Line API"
{
    PageType = API;
    SourceTable = "Item Journal Line";
    APIPublisher = 'Joe';
    APIGroup = 'inventory';
    APIVersion = 'v2.0';
    EntityName = 'itemJournalLineNew';
    EntitySetName = 'itemJournalLinesNew';

    // 关键：OData 主键用 SystemId
    ODataKeyFields = SystemId;

    // 允许插入，且不要把 DelayedInsert 设为 false
    InsertAllowed = true;
    DelayedInsert = true;
    Editable = true;
    // DelayedInsert = true; // 默认即为 true，不要改为 false

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(id; Rec.SystemId) { ApplicationArea = All; Editable = false; }
                field(journalTemplateName; Rec."Journal Template Name") { }
                field(journalBatchName; Rec."Journal Batch Name") { }
                field(lineNo; Rec."Line No.") { Editable = false; }
                field(itemNumber; Rec."Item No.") { }
                field(locationCode; Rec."Location Code") { }
                field(variantCode; Rec."Variant Code") { }
                field(entryType; Rec."Entry Type") { } // Purchase/Sale/PositiveAdjmt/NegativeAdjmt
                field(quantity; Rec.Quantity) { }
                field(unitOfMeasureCode; Rec."Unit of Measure Code") { }
                field(postingDate; Rec."Posting Date") { }
                field(description; Rec.Description) { }
                field(documentNo; Rec."Document No.") { }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        L: Record "Item Journal Line";
        NextNo: Integer;
    begin
        // 只计算行号，不要自己 Rec.Insert()，也不要返回 true
        if Rec."Line No." = 0 then begin
            L.SetRange("Journal Template Name", Rec."Journal Template Name");
            L.SetRange("Journal Batch Name", Rec."Journal Batch Name");
            if L.FindLast() then
                NextNo := L."Line No." + 10000
            else
                NextNo := 10000;
            Rec."Line No." := NextNo;
        end;

        exit(true); // Important关键：返回 false 让平台继续执行真正的插入
    end;
}
