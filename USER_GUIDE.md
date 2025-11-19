# CashMemo App - Quick Start Guide

## 🎯 Overview
CashMemo is a complete grocery shop management application with professional cash memo generation and printing capabilities.

## 📱 Key Features

### 1. Dashboard (Home Screen)
- View quick stats: Total products, customers, and cash memos
- Quick access to create new cash memo
- Navigation to all sections

### 2. Products Management
- **Add Product**: Click + button, fill details (name, price, unit, stock)
- **Edit Product**: Click menu (⋮) > Edit on any product
- **Delete Product**: Click menu (⋮) > Delete
- **Search Products**: Type in search box to filter

### 3. Customers Management
- **Add Customer**: Click + button, enter name, phone, email, address
- **Edit Customer**: Click menu > Edit
- **Delete Customer**: Click menu > Delete
- **Search Customers**: Use search box

### 4. Create Cash Memo
- Click "New Cash Memo" button from dashboard
- Select customer (optional - can use "Walk-in Customer")
- Add items:
  - Click "Add Item"
  - Select product from dropdown
  - Enter quantity
  - Item is added to list
- Adjust discount and tax if needed
- Choose:
  - **Save**: Saves memo to database
  - **Save & Print**: Saves and opens PDF for printing

### 5. View Cash Memos
- See all generated cash memos
- Each memo shows:
  - Memo number
  - Date and time
  - Customer name
  - Total amount
- Actions:
  - **Print Icon**: Reprint the memo
  - **Delete Icon**: Remove the memo

### 6. Settings
- Configure shop information:
  - Shop name
  - Address
  - Phone number
  - Email
  - GST number
- This information appears on printed cash memos

## 🖨️ Printing Cash Memos

1. **During Creation**: Use "Save & Print" button
2. **From List**: Click print icon on any existing memo
3. PDF preview will open
4. Choose printer and print

### PDF Contains:
- Shop name and contact details
- Memo number and date
- Customer information (if selected)
- Itemized list of products with quantities and prices
- Subtotal, discount, tax
- Total amount
- Professional formatting

## 💡 Tips

### Product Management
- Keep stock quantities updated
- Use clear product names
- Specify units (kg, pcs, liters, etc.)
- Add descriptions for better identification

### Customer Management
- Not mandatory for cash memos
- Useful for frequent customers
- Phone numbers help for follow-ups

### Creating Cash Memos
- Memo numbers are auto-generated (CM + Date + Sequence)
- Format: CM20241119001
- Can add multiple items in one memo
- Discount and tax are optional

### Responsive Design
- **Mobile View**: Bottom navigation bar
- **Desktop View**: Side navigation rail
- Works perfectly on both small and large screens

## 🔧 Troubleshooting

### App won't start
- Ensure Flutter SDK is installed
- Run: `flutter pub get`
- Try: `flutter clean` then `flutter run`

### Database issues
- App creates database automatically on first run
- Located in app's data directory
- Restart app if data doesn't appear

### PDF not generating
- Ensure "printing" package is installed
- Check printer drivers on Windows
- Try "Save" first, then print from list

## 🚀 Running the App

### On Windows:
```bash
flutter run -d windows
```

### On Android:
```bash
flutter run
```
(Make sure device is connected or emulator is running)

## 📊 Sample Workflow

1. **Setup** (First Time):
   - Open Settings
   - Enter shop name and details
   - Save settings

2. **Add Inventory**:
   - Go to Products
   - Add your grocery items
   - Include prices and stock

3. **Add Customers** (Optional):
   - Go to Customers
   - Add frequent customers

4. **Create First Memo**:
   - Click "New Cash Memo"
   - Select/skip customer
   - Add items
   - Save & Print

5. **Daily Use**:
   - Create cash memos as needed
   - View history in Cash Memos screen
   - Reprint if needed

## 🎨 UI Navigation

### Mobile (Bottom Navigation):
- Dashboard | Products | Customers | Memos | Settings

### Desktop (Side Navigation Rail):
- Dashboard
- Products
- Customers
- Cash Memos
- Settings

## 📈 Best Practices

1. **Regular Updates**:
   - Update stock after sales
   - Keep customer info current
   - Review old cash memos periodically

2. **Backup**:
   - Database is local
   - Consider periodic exports (future feature)

3. **Settings**:
   - Keep shop info updated
   - Verify GST number if applicable

4. **Organization**:
   - Use consistent product naming
   - Group similar items
   - Regular stock checks

## ✅ System Requirements

- **Windows**: Windows 10 or later
- **Android**: Android 5.0 (API 21) or higher
- **RAM**: Minimum 2GB
- **Storage**: ~100MB for app + data

## 🆘 Support

For issues or questions:
1. Check this guide first
2. Verify app is up to date
3. Try restarting the app
4. Check console for error messages

---

**Enjoy using CashMemo for your grocery shop management!** 🛒📄
