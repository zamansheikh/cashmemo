import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/cash_memo.dart';
import '../../domain/entities/shop_settings.dart';
import '../constants/app_constants.dart';

class PdfService {
  static Future<void> generateAndPrintCashMemo(
    CashMemo cashMemo,
    ShopSettings? shopSettings,
  ) async {
    // Create PDF document
    final PdfDocument document = PdfDocument();
    document.pageSettings.size = PdfPageSize.a4;
    document.pageSettings.margins.all = 0;

    // Load fonts
    final ByteData regularFontData = await rootBundle.load(
      'assets/Noto_Serif_Bengali/static/NotoSerifBengali-Regular.ttf',
    );
    final ByteData boldFontData = await rootBundle.load(
      'assets/Noto_Serif_Bengali/static/NotoSerifBengali-Bold.ttf',
    );

    final PdfFont regularFont = PdfTrueTypeFont(
      regularFontData.buffer.asUint8List(),
      10,
    );
    final PdfFont boldFont = PdfTrueTypeFont(
      boldFontData.buffer.asUint8List(),
      10,
    );
    final PdfFont mediumFont = PdfTrueTypeFont(
      boldFontData.buffer.asUint8List(),
      12,
    );
    final PdfFont headerFont = PdfTrueTypeFont(
      boldFontData.buffer.asUint8List(),
      20,
    );
    final PdfFont titleFont = PdfTrueTypeFont(
      boldFontData.buffer.asUint8List(),
      16,
    );
    final PdfFont smallFont = PdfTrueTypeFont(
      regularFontData.buffer.asUint8List(),
      8,
    );

    // Initial Page
    PdfPage currentPage = document.pages.add();
    final double pageWidth = currentPage.getClientSize().width;
    final double pageHeight = currentPage.getClientSize().height;
    final double margin = 40;
    double yPosition = margin;

    // Draw Header
    yPosition = _drawHeader(
      currentPage.graphics,
      shopSettings,
      cashMemo,
      headerFont,
      mediumFont,
      regularFont,
      titleFont,
      yPosition,
      pageWidth,
      margin,
    );

    yPosition += 20;

    // Draw Customer Details
    yPosition = _drawCustomerDetails(
      currentPage.graphics,
      cashMemo,
      boldFont,
      regularFont,
      yPosition,
      pageWidth,
      margin,
    );

    yPosition += 15;

    // Draw Items Table
    final PdfLayoutResult result = _drawItemsTable(
      currentPage,
      cashMemo,
      boldFont,
      regularFont,
      yPosition,
      pageWidth,
      margin,
    );

    currentPage = result.page;
    yPosition = result.bounds.bottom + 20;

    // Draw Totals
    // Check if we need a new page for totals
    if (yPosition + 150 > pageHeight - margin) {
      currentPage = document.pages.add();
      yPosition = margin;
    }

    _drawTotals(
      currentPage.graphics,
      cashMemo,
      mediumFont,
      regularFont,
      boldFont,
      yPosition,
      pageWidth,
      margin,
    );

    // Draw Footer on the last page
    _drawFooter(
      currentPage.graphics,
      boldFont,
      smallFont,
      pageHeight,
      pageWidth,
      margin,
    );

    // Draw Border on all pages
    for (int i = 0; i < document.pages.count; i++) {
      final PdfPage p = document.pages[i];
      p.graphics.drawRectangle(
        pen: PdfPen(PdfColor(46, 125, 50), width: 1),
        bounds: Rect.fromLTWH(20, 20, pageWidth - 40, pageHeight - 40),
      );
    }

    // Save and print
    final List<int> bytes = await document.save();
    document.dispose();

    await Printing.layoutPdf(
      onLayout: (format) async => Uint8List.fromList(bytes),
    );
  }

  static double _drawHeader(
    PdfGraphics graphics,
    ShopSettings? settings,
    CashMemo cashMemo,
    PdfFont headerFont,
    PdfFont mediumFont,
    PdfFont regularFont,
    PdfFont titleFont,
    double yPosition,
    double pageWidth,
    double margin,
  ) {
    final double contentWidth = pageWidth - (margin * 2);

    // Left Side: Shop Info
    double leftY = yPosition;
    final String shopName = settings?.shopName.toUpperCase() ?? 'GROCERY SHOP';
    graphics.drawString(
      shopName,
      headerFont,
      brush: PdfSolidBrush(PdfColor(46, 125, 50)),
      bounds: Rect.fromLTWH(margin, leftY, contentWidth / 2, 25),
    );
    leftY += 25;

    if (settings?.address != null && settings!.address!.isNotEmpty) {
      graphics.drawString(
        settings.address!,
        regularFont,
        bounds: Rect.fromLTWH(
          margin,
          leftY,
          contentWidth / 2,
          40,
        ), // Allow multiline
        format: PdfStringFormat(lineAlignment: PdfVerticalAlignment.top),
      );
      // Estimate height
      final Size size = regularFont.measureString(
        settings.address!,
        layoutArea: Size(contentWidth / 2, 40),
      );
      leftY += size.height + 5;
    }

    String contactInfo = '';
    if (settings?.phone != null && settings!.phone!.isNotEmpty) {
      contactInfo = 'Phone: ${settings.phone}';
    }
    if (settings?.email != null && settings!.email!.isNotEmpty) {
      if (contactInfo.isNotEmpty) contactInfo += '\n';
      contactInfo += 'Email: ${settings.email}';
    }
    if (contactInfo.isNotEmpty) {
      graphics.drawString(
        contactInfo,
        regularFont,
        bounds: Rect.fromLTWH(margin, leftY, contentWidth / 2, 40),
      );
      final Size size = regularFont.measureString(
        contactInfo,
        layoutArea: Size(contentWidth / 2, 40),
      );
      leftY += size.height + 5;
    }

    if (settings?.gstNumber != null && settings!.gstNumber!.isNotEmpty) {
      graphics.drawString(
        'GST: ${settings.gstNumber}',
        regularFont,
        bounds: Rect.fromLTWH(margin, leftY, contentWidth / 2, 15),
      );
      leftY += 15;
    }

    // Right Side: Invoice Info
    double rightY = yPosition;
    final String title = 'CASH MEMO';
    final Size titleSize = titleFont.measureString(title);
    graphics.drawString(
      title,
      titleFont,
      brush: PdfSolidBrush(PdfColor(46, 125, 50)),
      bounds: Rect.fromLTWH(
        pageWidth - margin - titleSize.width,
        rightY,
        titleSize.width,
        20,
      ),
    );
    rightY += 25;

    final String memoNo = 'Memo No: ${cashMemo.memoNumber}';
    final Size memoSize = mediumFont.measureString(memoNo);
    graphics.drawString(
      memoNo,
      mediumFont,
      bounds: Rect.fromLTWH(
        pageWidth - margin - memoSize.width,
        rightY,
        memoSize.width,
        15,
      ),
    );
    rightY += 18;

    final String dateText =
        'Date: ${DateFormat(AppConstants.dateFormat).format(cashMemo.date)}';
    final Size dateSize = regularFont.measureString(dateText);
    graphics.drawString(
      dateText,
      regularFont,
      bounds: Rect.fromLTWH(
        pageWidth - margin - dateSize.width,
        rightY,
        dateSize.width,
        15,
      ),
    );
    rightY += 15;

    final String timeText =
        'Time: ${DateFormat('hh:mm a').format(cashMemo.date)}';
    final Size timeSize = regularFont.measureString(timeText);
    graphics.drawString(
      timeText,
      regularFont,
      bounds: Rect.fromLTWH(
        pageWidth - margin - timeSize.width,
        rightY,
        timeSize.width,
        15,
      ),
    );
    rightY += 15;

    // Return the max Y
    double maxY = leftY > rightY ? leftY : rightY;

    // Draw separator line
    graphics.drawLine(
      PdfPen(PdfColor(46, 125, 50), width: 1),
      Offset(margin, maxY + 5),
      Offset(pageWidth - margin, maxY + 5),
    );

    return maxY + 10;
  }

  static double _drawCustomerDetails(
    PdfGraphics graphics,
    CashMemo cashMemo,
    PdfFont boldFont,
    PdfFont regularFont,
    double yPosition,
    double pageWidth,
    double margin,
  ) {
    if (cashMemo.customerName == null && cashMemo.customerPhone == null) {
      return yPosition;
    }

    graphics.drawString(
      'Bill To:',
      boldFont,
      bounds: Rect.fromLTWH(margin, yPosition, 100, 15),
    );
    yPosition += 15;

    if (cashMemo.customerName != null) {
      graphics.drawString(
        cashMemo.customerName!,
        regularFont,
        bounds: Rect.fromLTWH(margin, yPosition, 300, 15),
      );
      yPosition += 15;
    }

    if (cashMemo.customerPhone != null && cashMemo.customerPhone!.isNotEmpty) {
      graphics.drawString(
        'Phone: ${cashMemo.customerPhone}',
        regularFont,
        bounds: Rect.fromLTWH(margin, yPosition, 300, 15),
      );
      yPosition += 15;
    }

    if (cashMemo.customerAddress != null &&
        cashMemo.customerAddress!.isNotEmpty) {
      graphics.drawString(
        cashMemo.customerAddress!,
        regularFont,
        bounds: Rect.fromLTWH(margin, yPosition, 300, 30), // Allow multiline
      );
      yPosition += 30;
    }

    return yPosition;
  }

  static PdfLayoutResult _drawItemsTable(
    PdfPage page,
    CashMemo cashMemo,
    PdfFont boldFont,
    PdfFont regularFont,
    double yPosition,
    double pageWidth,
    double margin,
  ) {
    final PdfGrid grid = PdfGrid();
    grid.columns.add(count: 5);

    final double tableWidth = pageWidth - (margin * 2);
    grid.columns[0].width = tableWidth * 0.08; // S.No
    grid.columns[1].width = tableWidth * 0.40; // Item
    grid.columns[2].width = tableWidth * 0.15; // Qty
    grid.columns[3].width = tableWidth * 0.17; // Price
    grid.columns[4].width = tableWidth * 0.20; // Amount

    final PdfGridRow headerRow = grid.headers.add(1)[0];
    headerRow.cells[0].value = 'S.No';
    headerRow.cells[1].value = 'Item';
    headerRow.cells[2].value = 'Qty';
    headerRow.cells[3].value = 'Price';
    headerRow.cells[4].value = 'Amount';

    for (int i = 0; i < 5; i++) {
      headerRow.cells[i].style = PdfGridCellStyle(
        font: boldFont,
        backgroundBrush: PdfSolidBrush(PdfColor(46, 125, 50)),
        textBrush: PdfSolidBrush(PdfColor(255, 255, 255)),
        cellPadding: PdfPaddings(left: 5, right: 5, top: 8, bottom: 8),
      );
      if (i >= 2) {
        headerRow.cells[i].stringFormat = PdfStringFormat(
          alignment: PdfTextAlignment.right,
        );
      }
    }

    for (int i = 0; i < cashMemo.items.length; i++) {
      final item = cashMemo.items[i];
      final PdfGridRow row = grid.rows.add();

      row.cells[0].value = '${i + 1}';
      row.cells[1].value = item.productName;
      row.cells[2].value = '${item.quantity} ${item.unit}';
      row.cells[3].value =
          '${AppConstants.currencySymbol}${item.price.toStringAsFixed(2)}';
      row.cells[4].value =
          '${AppConstants.currencySymbol}${item.total.toStringAsFixed(2)}';

      for (int j = 0; j < 5; j++) {
        row.cells[j].style = PdfGridCellStyle(
          font: regularFont,
          cellPadding: PdfPaddings(left: 5, right: 5, top: 5, bottom: 5),
          backgroundBrush: i % 2 == 0
              ? PdfSolidBrush(PdfColor(255, 255, 255))
              : PdfSolidBrush(PdfColor(248, 250, 248)),
          borders: PdfBorders(
            left: PdfPen(PdfColor(200, 200, 200), width: 0.5),
            right: PdfPen(PdfColor(200, 200, 200), width: 0.5),
            top: PdfPen(PdfColor(200, 200, 200), width: 0.5),
            bottom: PdfPen(PdfColor(200, 200, 200), width: 0.5),
          ),
        );
        if (j >= 2) {
          row.cells[j].stringFormat = PdfStringFormat(
            alignment: PdfTextAlignment.right,
          );
        }
      }
    }

    grid.style = PdfGridStyle(
      cellPadding: PdfPaddings(left: 5, right: 5, top: 5, bottom: 5),
      borderOverlapStyle: PdfBorderOverlapStyle.inside,
      font: regularFont,
    );

    final PdfLayoutResult result = grid.draw(
      page: page,
      bounds: Rect.fromLTWH(margin, yPosition, tableWidth, 0),
    )!;

    return result;
  }

  static void _drawTotals(
    PdfGraphics graphics,
    CashMemo cashMemo,
    PdfFont mediumFont,
    PdfFont regularFont,
    PdfFont boldFont,
    double yPosition,
    double pageWidth,
    double margin,
  ) {
    final double width = 200;
    final double startX = pageWidth - margin - width;

    // Subtotal
    graphics.drawString(
      'Subtotal:',
      regularFont,
      bounds: Rect.fromLTWH(startX, yPosition, width / 2, 15),
    );
    graphics.drawString(
      '${AppConstants.currencySymbol}${cashMemo.subtotal.toStringAsFixed(2)}',
      regularFont,
      bounds: Rect.fromLTWH(startX + width / 2, yPosition, width / 2, 15),
      format: PdfStringFormat(alignment: PdfTextAlignment.right),
    );
    yPosition += 20;

    // Discount
    if (cashMemo.discount > 0) {
      graphics.drawString(
        'Discount:',
        regularFont,
        bounds: Rect.fromLTWH(startX, yPosition, width / 2, 15),
      );
      graphics.drawString(
        '- ${AppConstants.currencySymbol}${cashMemo.discount.toStringAsFixed(2)}',
        regularFont,
        brush: PdfSolidBrush(PdfColor(200, 0, 0)),
        bounds: Rect.fromLTWH(startX + width / 2, yPosition, width / 2, 15),
        format: PdfStringFormat(alignment: PdfTextAlignment.right),
      );
      yPosition += 20;
    }

    // Tax
    if (cashMemo.tax > 0) {
      graphics.drawString(
        'Tax:',
        regularFont,
        bounds: Rect.fromLTWH(startX, yPosition, width / 2, 15),
      );
      graphics.drawString(
        '${AppConstants.currencySymbol}${cashMemo.tax.toStringAsFixed(2)}',
        regularFont,
        bounds: Rect.fromLTWH(startX + width / 2, yPosition, width / 2, 15),
        format: PdfStringFormat(alignment: PdfTextAlignment.right),
      );
      yPosition += 20;
    }

    // Divider
    graphics.drawLine(
      PdfPen(PdfColor(0, 0, 0), width: 1),
      Offset(startX, yPosition),
      Offset(startX + width, yPosition),
    );
    yPosition += 10;

    // Total
    graphics.drawString(
      'Total:',
      boldFont,
      bounds: Rect.fromLTWH(startX, yPosition, width / 2, 20),
    );
    graphics.drawString(
      '${AppConstants.currencySymbol}${cashMemo.total.toStringAsFixed(2)}',
      boldFont,
      brush: PdfSolidBrush(PdfColor(46, 125, 50)),
      bounds: Rect.fromLTWH(startX + width / 2, yPosition, width / 2, 20),
      format: PdfStringFormat(alignment: PdfTextAlignment.right),
    );
  }

  static void _drawFooter(
    PdfGraphics graphics,
    PdfFont boldFont,
    PdfFont smallFont,
    double pageHeight,
    double pageWidth,
    double margin,
  ) {
    double yPosition = pageHeight - 60;

    // Thank you message
    final String thankYouText = 'Thank you for your business!';
    final Size thankYouSize = boldFont.measureString(thankYouText);
    graphics.drawString(
      thankYouText,
      boldFont,
      brush: PdfSolidBrush(PdfColor(46, 125, 50)),
      bounds: Rect.fromLTWH(
        (pageWidth - thankYouSize.width) / 2,
        yPosition,
        thankYouSize.width,
        thankYouSize.height,
      ),
    );
    yPosition += 20;

    // Generated text
    final String generatedText = 'This is a computer-generated cash memo';
    final Size generatedSize = smallFont.measureString(generatedText);
    graphics.drawString(
      generatedText,
      smallFont,
      brush: PdfSolidBrush(PdfColor(120, 120, 120)),
      bounds: Rect.fromLTWH(
        (pageWidth - generatedSize.width) / 2,
        yPosition,
        generatedSize.width,
        generatedSize.height,
      ),
    );

    // Authorized Signatory
    final String signText = 'Authorized Signatory';
    final Size signSize = smallFont.measureString(signText);
    graphics.drawString(
      signText,
      smallFont,
      bounds: Rect.fromLTWH(
        pageWidth - margin - signSize.width,
        pageHeight - 80,
        signSize.width,
        signSize.height,
      ),
    );
    graphics.drawLine(
      PdfPen(PdfColor(0, 0, 0), width: 0.5),
      Offset(pageWidth - margin - signSize.width - 10, pageHeight - 85),
      Offset(pageWidth - margin + 10, pageHeight - 85),
    );
  }
}
