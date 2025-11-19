import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:pdf/pdf.dart' show PdfPageFormat;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
// Update these imports based on your actual folder structure
import '../../domain/entities/cash_memo.dart';
import '../../domain/entities/shop_settings.dart';
import '../constants/app_constants.dart';

class PdfService {
  // Colors
  static final PdfColor _yellowColor = PdfColor(255, 193, 7); // Amber
  static final PdfColor _darkColor = PdfColor(51, 51, 51);
  static final PdfColor _lightGrayColor = PdfColor(245, 245, 245);
  static final PdfColor _textColor = PdfColor(60, 60, 60);
  static final PdfColor _whiteColor = PdfColor(255, 255, 255);

  static Future<void> generateAndPrintCashMemo(
    CashMemo cashMemo,
    ShopSettings shopSettings,
  ) async {
    final PdfDocument document = PdfDocument();
    document.pageSettings.size = PdfPageSize.a4;
    document.pageSettings.margins.all = 0;

    // Load fonts
    final ByteData regularData = await rootBundle.load(
      'assets/Noto_Serif_Bengali/static/NotoSerifBengali-Regular.ttf',
    );
    final ByteData boldData = await rootBundle.load(
      'assets/Noto_Serif_Bengali/static/NotoSerifBengali-Bold.ttf',
    );

    final PdfFont regularFont = PdfTrueTypeFont(
      regularData.buffer.asUint8List(),
      10,
    );
    final PdfFont boldFont = PdfTrueTypeFont(
      boldData.buffer.asUint8List(),
      10,
      style: PdfFontStyle.bold,
    );
    // Font for Shop Name
    final PdfFont titleFont = PdfTrueTypeFont(
      boldData.buffer.asUint8List(),
      24,
      style: PdfFontStyle.bold,
    );
    // Big Font for "INVOICE" title
    final PdfFont headerLabelFont = PdfTrueTypeFont(
      boldData.buffer.asUint8List(),
      35, // Big size like the reference image
      style: PdfFontStyle.bold,
    );
    final PdfFont mediumFont = PdfTrueTypeFont(
      boldData.buffer.asUint8List(),
      14,
      style: PdfFontStyle.bold,
    );

    final PdfPage page = document.pages.add();
    final PdfGraphics g = page.graphics;
    final double pageWidth = page.getClientSize().width;
    final double pageHeight = page.getClientSize().height;
    final double margin = 40;

    double y = 40;

    // 1. Header (Logo + Brand + Yellow Bar + INVOICE Text)
    y = _drawHeader(
      g,
      shopSettings,
      titleFont,
      regularFont,
      headerLabelFont,
      pageWidth,
      y,
      margin,
    );

    // 2. Invoice Info (To: / Date / #)
    y = _drawInvoiceInfo(
      g,
      cashMemo,
      mediumFont,
      boldFont,
      regularFont,
      y,
      pageWidth,
      margin,
    );

    // 3. Items Table
    final PdfLayoutResult tableResult = _drawItemsTable(
      page,
      cashMemo,
      boldFont,
      regularFont,
      y + 20,
      pageWidth,
      margin,
    );

    // 4. Footer Section (Terms, Payment, Totals)
    // We pass 'page' to use PdfTextElement for dynamic height calculation
    y = _drawFooterSection(
      page,
      cashMemo,
      shopSettings,
      mediumFont,
      boldFont,
      regularFont,
      tableResult.bounds.bottom + 30, // Start below table
      pageWidth,
      margin,
    );

    // 5. Bottom Bar (Contact + Signature)
    _drawBottomBar(g, shopSettings, pageWidth, pageHeight, margin, regularFont);

    // Save & Print
    final List<int> bytes = await document.save();
    document.dispose();

    await Printing.layoutPdf(
      onLayout: (_) => Future.value(Uint8List.fromList(bytes)),
    );
  }

  // --- 1. HEADER SECTION ---
  static double _drawHeader(
    PdfGraphics g,
    ShopSettings s,
    PdfFont titleFont,
    PdfFont tagFont,
    PdfFont invoiceLabelFont,
    double width,
    double y,
    double margin,
  ) {
    const double logoSize = 36;

    // -- A. Logo & Brand Name (Top Left) --
    g.drawPolygon([
      Offset(margin + logoSize / 2, y),
      Offset(margin + logoSize, y + logoSize / 2),
      Offset(margin + logoSize / 2, y + logoSize),
      Offset(margin, y + logoSize / 2),
    ], pen: PdfPen(_darkColor, width: 2.5));

    final double textX = margin + logoSize + 15;

    // Draw Shop Name (Height increased to avoid cutting off)
    g.drawString(
      s.shopName.isNotEmpty ? s.shopName : "Brand Name",
      titleFont,
      brush: PdfSolidBrush(_darkColor),
      bounds: Rect.fromLTWH(textX, y - 5, 400, 40),
      format: PdfStringFormat(lineAlignment: PdfVerticalAlignment.middle),
    );

    // Draw Tagline
    g.drawString(
      s.tagline ?? 'Your tagline here',
      tagFont,
      brush: PdfSolidBrush(_textColor),
      bounds: Rect.fromLTWH(textX, y + 35, 300, 20),
    );

    // -- B. Yellow Bar & "INVOICE" Text --
    // Move down below the logo
    double barY = y + 70;
    double barHeight = 35;

    // Measure "INVOICE" text width to calculate gaps
    final Size invoiceTextSize = invoiceLabelFont.measureString('INVOICE');

    // Layout: [Yellow Bar 55%] [ Gap ] [ INVOICE Text ] [ Gap ] [ Yellow Bar Rest ]

    double leftBarWidth = width * 0.55;
    double invoiceTextX = leftBarWidth + 15; // 15 padding
    double rightBarStartX = invoiceTextX + invoiceTextSize.width + 15;
    double rightBarWidth = width - rightBarStartX;

    // 1. Left Yellow Bar
    g.drawRectangle(
      bounds: Rect.fromLTWH(0, barY, leftBarWidth, barHeight),
      brush: PdfSolidBrush(_yellowColor),
    );

    // 2. INVOICE Text (Vertically centered relative to bar)
    // We adjust Y slightly up because the font is huge
    g.drawString(
      'INVOICE',
      invoiceLabelFont,
      brush: PdfSolidBrush(_darkColor),
      bounds: Rect.fromLTWH(
        invoiceTextX,
        barY - 6, // Slight offset to align baseline
        invoiceTextSize.width,
        invoiceTextSize.height,
      ),
    );

    // 3. Right Yellow Bar
    if (rightBarWidth > 0) {
      g.drawRectangle(
        bounds: Rect.fromLTWH(rightBarStartX, barY, rightBarWidth, barHeight),
        brush: PdfSolidBrush(_yellowColor),
      );
    }

    return barY + barHeight + 40; // Return Y position for next section
  }

  // --- 2. INVOICE INFO ---
  static double _drawInvoiceInfo(
    PdfGraphics g,
    CashMemo cm,
    PdfFont title,
    PdfFont bold,
    PdfFont regular,
    double y,
    double width,
    double margin,
  ) {
    double maxY = y;

    // Left Side: Customer Info
    g.drawString(
      'Invoice to:',
      title,
      brush: PdfSolidBrush(_darkColor),
      bounds: Rect.fromLTWH(margin, y, 200, 25),
    );
    double leftY = y + 30;

    if (cm.customerName != null && cm.customerName!.isNotEmpty) {
      g.drawString(
        cm.customerName!,
        bold,
        brush: PdfSolidBrush(_textColor),
        bounds: Rect.fromLTWH(margin, leftY, 280, 20),
      );
      leftY += 22;
    }
    if (cm.customerAddress != null && cm.customerAddress!.isNotEmpty) {
      // Allow address to wrap 2-3 lines
      g.drawString(
        cm.customerAddress!,
        regular,
        brush: PdfSolidBrush(_textColor),
        bounds: Rect.fromLTWH(margin, leftY, 280, 50),
        format: PdfStringFormat(lineAlignment: PdfVerticalAlignment.top),
      );
      leftY += 50;
    }
    maxY = leftY > maxY ? leftY : maxY;

    // Right Side: Invoice # & Date
    double rightY = y + 5;
    final double rightX = width - margin - 250;

    // Invoice Number
    g.drawString(
      'Invoice#',
      bold,
      brush: PdfSolidBrush(_darkColor),
      bounds: Rect.fromLTWH(rightX, rightY, 90, 20),
    );
    g.drawString(
      cm.memoNumber,
      bold,
      brush: PdfSolidBrush(_textColor),
      bounds: Rect.fromLTWH(rightX + 100, rightY, 150, 20),
      format: PdfStringFormat(alignment: PdfTextAlignment.right),
    );
    rightY += 25;

    // Date
    g.drawString(
      'Date',
      bold,
      brush: PdfSolidBrush(_darkColor),
      bounds: Rect.fromLTWH(rightX, rightY, 90, 20),
    );
    g.drawString(
      DateFormat('dd / MM / yyyy').format(cm.date),
      bold,
      brush: PdfSolidBrush(_textColor),
      bounds: Rect.fromLTWH(rightX + 100, rightY, 150, 20),
      format: PdfStringFormat(alignment: PdfTextAlignment.right),
    );

    return maxY > rightY + 30 ? maxY + 20 : rightY + 50;
  }

  // --- 3. ITEMS TABLE ---
  static PdfLayoutResult _drawItemsTable(
    PdfPage page,
    CashMemo cm,
    PdfFont bold,
    PdfFont regular,
    double y,
    double width,
    double margin,
  ) {
    final PdfGrid grid = PdfGrid();
    grid.columns.add(count: 5);
    final double tableWidth = width - margin * 2;

    // Column widths
    grid.columns[0].width = tableWidth * 0.08; // SL
    grid.columns[1].width = tableWidth * 0.42; // Desc
    grid.columns[2].width = tableWidth * 0.15; // Price
    grid.columns[3].width = tableWidth * 0.15; // Qty
    grid.columns[4].width = tableWidth * 0.20; // Total

    // Header
    final PdfGridRow header = grid.headers.add(1)[0];
    header.cells[0].value = 'SL.';
    header.cells[1].value = 'Item Description';
    header.cells[2].value = 'Price';
    header.cells[3].value = 'Qty.';
    header.cells[4].value = 'Total';

    for (int i = 0; i < 5; i++) {
      header.cells[i].style = PdfGridCellStyle(
        backgroundBrush: PdfSolidBrush(_darkColor),
        textBrush: PdfSolidBrush(_whiteColor),
        font: bold,
        cellPadding: PdfPaddings(left: 6, top: 8, right: 6, bottom: 8),
      );
      header.cells[i].stringFormat = PdfStringFormat(
        alignment: i < 2 ? PdfTextAlignment.left : PdfTextAlignment.right,
        lineAlignment: PdfVerticalAlignment.middle,
      );
    }

    // Rows
    for (int i = 0; i < cm.items.length; i++) {
      final item = cm.items[i];
      final row = grid.rows.add();
      row.cells[0].value = '${i + 1}';
      row.cells[1].value = item.productName;
      row.cells[2].value = item.price.toStringAsFixed(2);
      row.cells[3].value = item.quantity.toString();
      row.cells[4].value = item.total.toStringAsFixed(2);

      final color = i.isEven ? _whiteColor : _lightGrayColor;
      for (int j = 0; j < 5; j++) {
        row.cells[j].style = PdfGridCellStyle(
          backgroundBrush: PdfSolidBrush(color),
          textBrush: PdfSolidBrush(_textColor),
          font: regular,
          cellPadding: PdfPaddings(left: 6, top: 8, right: 6, bottom: 8),
        );
        row.cells[j].stringFormat = PdfStringFormat(
          alignment: j < 2 ? PdfTextAlignment.left : PdfTextAlignment.right,
          lineAlignment: PdfVerticalAlignment.middle,
        );
      }
    }

    return grid.draw(
      page: page,
      bounds: Rect.fromLTWH(margin, y, tableWidth, 0),
    )!;
  }

  // --- 4. FOOTER (Fixing Overlap) ---
  static double _drawFooterSection(
    PdfPage page,
    CashMemo cm,
    ShopSettings? settings,
    PdfFont medium,
    PdfFont bold,
    PdfFont regular,
    double y,
    double width,
    double margin,
  ) {
    final PdfGraphics g = page.graphics;
    double currentY = y;

    // Thank You Text
    g.drawString(
      'Thank you for your business',
      bold,
      brush: PdfSolidBrush(_darkColor),
      bounds: Rect.fromLTWH(margin, currentY, 350, 25),
    );
    currentY += 35;

    // We split the footer into Left (Terms/Payment) and Right (Totals)
    double leftSideY = currentY;
    double rightSideY = currentY;

    // --- LEFT SIDE ---

    // 1. Terms Header
    g.drawString(
      'Terms & Conditions',
      bold,
      brush: PdfSolidBrush(_darkColor),
      bounds: Rect.fromLTWH(margin, leftSideY, 300, 20),
    );
    leftSideY += 22;

    // 2. Terms Body (Dynamic Layout to prevent overlap)
    String termsText =
        settings?.terms ??
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce dignissim pretium consectetur.';

    // Create a Text Element
    PdfTextElement termsElement = PdfTextElement(
      text: termsText,
      font: regular,
      brush: PdfSolidBrush(_textColor),
      format: PdfStringFormat(lineAlignment: PdfVerticalAlignment.top),
    );

    // Draw it constrained to width (300) so it doesn't hit the totals
    PdfLayoutResult? termsResult = termsElement.draw(
      page: page,
      bounds: Rect.fromLTWH(margin, leftSideY, 300, 0),
    );

    // Update Y to the bottom of the drawn text + padding
    if (termsResult != null) {
      leftSideY = termsResult.bounds.bottom + 25;
    } else {
      leftSideY += 40;
    }

    // 3. Payment Info (Drawn BELOW the dynamic terms)
    g.drawString(
      'Payment Info:',
      bold,
      brush: PdfSolidBrush(_darkColor),
      bounds: Rect.fromLTWH(margin, leftSideY, 200, 20),
    );
    leftSideY += 22;

    final paymentLines = [
      ['Account #:', '1234 5678 9012'],
      ['A/C Name:', settings?.shopName ?? 'Shop Name'],
      ['Bank:', 'Your Bank Details'],
    ];

    for (var line in paymentLines) {
      g.drawString(
        line[0],
        bold,
        brush: PdfSolidBrush(_darkColor),
        bounds: Rect.fromLTWH(margin, leftSideY, 80, 18),
      );
      g.drawString(
        line[1],
        regular,
        brush: PdfSolidBrush(_textColor),
        bounds: Rect.fromLTWH(margin + 85, leftSideY, 220, 18),
      );
      leftSideY += 18;
    }

    // --- RIGHT SIDE (Totals) ---
    final double rightX = width - margin - 260;
    final double boxWidth = 260;

    // Subtotal
    _drawTotalLine(
      g,
      'Sub Total:',
      cm.subtotal,
      bold,
      rightX,
      rightSideY,
      boxWidth,
    );
    rightSideY += 28;

    // Tax
    _drawTotalLine(g, 'Tax:', cm.tax, bold, rightX, rightSideY, boxWidth);
    rightSideY += 35;

    // Yellow Total Box
    g.drawRectangle(
      brush: PdfSolidBrush(_yellowColor),
      bounds: Rect.fromLTWH(rightX, rightSideY, boxWidth, 40),
    );
    g.drawString(
      'Total:',
      medium,
      brush: PdfSolidBrush(_darkColor),
      bounds: Rect.fromLTWH(rightX + 15, rightSideY + 10, 100, 25),
    );
    g.drawString(
      '${AppConstants.currencySymbol}${cm.total.toStringAsFixed(2)}',
      medium,
      brush: PdfSolidBrush(_darkColor),
      bounds: Rect.fromLTWH(rightX + 110, rightSideY + 10, boxWidth - 125, 25),
      format: PdfStringFormat(alignment: PdfTextAlignment.right),
    );
    rightSideY += 50;

    // Return the lowest point used (so bottom bar doesn't overlap)
    return leftSideY > rightSideY ? leftSideY : rightSideY;
  }

  static void _drawTotalLine(
    PdfGraphics g,
    String label,
    double value,
    PdfFont font,
    double x,
    double y,
    double width,
  ) {
    g.drawString(
      label,
      font,
      brush: PdfSolidBrush(_darkColor),
      bounds: Rect.fromLTWH(x, y, width / 2, 20),
    );
    g.drawString(
      '${AppConstants.currencySymbol}${value.toStringAsFixed(2)}',
      font,
      brush: PdfSolidBrush(_darkColor),
      bounds: Rect.fromLTWH(x + width / 2, y, width / 2 - 10, 20),
      format: PdfStringFormat(alignment: PdfTextAlignment.right),
    );
  }

  // --- 5. BOTTOM BAR ---
  static void _drawBottomBar(
    PdfGraphics g,
    ShopSettings? settings,
    double width,
    double height,
    double margin,
    PdfFont font,
  ) {
    final double barY = height - 45;

    // Yellow Line
    g.drawRectangle(
      bounds: Rect.fromLTWH(0, barY, width * 0.65, 4),
      brush: PdfSolidBrush(_yellowColor),
    );
    g.drawRectangle(
      bounds: Rect.fromLTWH(width * 0.88, barY, width * 0.12, 4),
      brush: PdfSolidBrush(_yellowColor),
    );

    // Contact Info
    g.drawString(
      'Phone # ${settings?.phone ?? ''}   |   Address ${settings?.address ?? ''}',
      font,
      brush: PdfSolidBrush(_darkColor),
      bounds: Rect.fromLTWH(margin + 10, height - 30, 450, 20),
    );

    // Signature Line
    final double signX = width - margin - 180;
    g.drawLine(
      PdfPen(_darkColor),
      Offset(signX, height - 70),
      Offset(signX + 180, height - 70),
    );
    g.drawString(
      'Authorised Sign',
      font,
      brush: PdfSolidBrush(_darkColor),
      bounds: Rect.fromLTWH(signX, height - 55, 180, 20),
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );
  }
}
