page 50139 "ItemJournalLine"
{
    PageType = API;
    Caption = 'Item Journal Line';
    SourceTable = "Item Journal Line";
    APIPublisher = 'joe';
    APIGroup = 'inventoryPosting';
    APIVersion = 'v2.0';
    EntityName = 'itemJournalLine';
    EntitySetName = 'itemJournalLines';
    ODataKeyFields = SystemId;              // 关键：用 SystemId 做主键

    // 允许插入/编辑。不要把 DelayedInsert 设为 false，否则 SystemId 会是 0000... 导致后续动作找不到
    InsertAllowed = true;
    Editable = true;
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                // 公开给外部的字段名建议用小驼峰，便于 Power Automate 映射
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                    ApplicationArea = All;
                    Editable = false;
                }
                field(journalTemplateName; Rec."Journal Template Name")
                {
                    Caption = 'Journal Template Name';
                    ApplicationArea = All;
                }
                field(journalBatchName; Rec."Journal Batch Name")
                {
                    Caption = 'Journal Batch Name';
                    ApplicationArea = All;
                }
                field(lineNo; Rec."Line No.")
                {
                    Caption = 'Line No.';
                    ApplicationArea = All;
                    Editable = false;       // 行号由系统生成，外部不要传
                }
                field(itemNumber; Rec."Item No.")
                {
                    Caption = 'Item No.';
                    ApplicationArea = All;
                }
                field(locationCode; Rec."Location Code")
                {
                    Caption = 'Location Code';
                    ApplicationArea = All;
                }
                field(variantCode; Rec."Variant Code")
                {
                    Caption = 'Variant Code';
                    ApplicationArea = All;
                }
                field(entryType; Rec."Entry Type")
                {
                    Caption = 'Entry Type';
                    ApplicationArea = All;  // Purchase/Sale/Positive Adjmt./Negative Adjmt.
                }
                field(quantity; Rec.Quantity)
                {
                    Caption = 'Quantity';
                    ApplicationArea = All;
                }
                field(unitOfMeasureCode; Rec."Unit of Measure Code")
                {
                    Caption = 'Unit of Measure Code';
                    ApplicationArea = All;
                }
                field(postingDate; Rec."Posting Date")
                {
                    Caption = 'Posting Date';
                    ApplicationArea = All;
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                    ApplicationArea = All;
                }
                field(documentNo; Rec."Document No.")
                {
                    Caption = 'Document No.';
                    ApplicationArea = All;
                }
            }
        }
    }

    // 自动分配 Line No.：以模板+批次为维度，10000 递增
    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        L: Record "Item Journal Line";
        NextNo: Integer;
    begin
        // 只负责给行号赋值，不要自己 Rec.Insert()，也不要返回 true
        if Rec."Line No." = 0 then begin
            L.Reset();
            L.SetRange("Journal Template Name", Rec."Journal Template Name");
            L.SetRange("Journal Batch Name", Rec."Journal Batch Name");
            if L.FindLast() then
                NextNo := L."Line No." + 10000
            else
                NextNo := 10000;
            Rec."Line No." := NextNo;
        end;

        exit(false); // 让平台继续执行插入，获得有效 SystemId
    end;

    // —— 单行过账 Action —— 
    // 绑定到当前记录（Rec），不需要任何参数
    [ServiceEnabled]
    procedure PostSingleLine(): Text
    var
        PostBatch: Codeunit "Item Jnl.-Post Batch";   // 用批过账引擎，只过滤到当前行
        Line: Record "Item Journal Line";
    begin
        // 校验：当前 API Page 要有记录上下文
        if IsNullGuid(Rec.SystemId) then
            Error('Current context has no record.');


        // 找到这条行
        Line.Reset();
        Line.SetRange("Journal Template Name", Rec."Journal Template Name");
        Line.SetRange("Journal Batch Name", Rec."Journal Batch Name");
        Line.SetRange("Line No.", Rec."Line No.");
        if not Line.FindFirst() then
            Error('Item Journal Line %1/%2/%3 not found.',
                Rec."Journal Template Name", Rec."Journal Batch Name", Rec."Line No.");

        // 过账此行（由于只过滤到这一行，批处理过账只会处理它）
        PostBatch.Run(Line);

        exit(StrSubstNo(
            'Posted line successfully: %1 / %2 / %3',
            Rec."Journal Template Name", Rec."Journal Batch Name", Rec."Line No."));
    end;
}
