# Invoice Tax & Claim Features

This document describes the tax and claim flags that have been added to the invoice system in the Medico app.

## Overview

The invoice system now includes two important boolean flags to track tax deduction and insurance claim eligibility:

- `isTaxDeductible`: Indicates whether the invoice amount can be claimed for tax deductions
- `isClaimable`: Indicates whether the invoice can be submitted for insurance reimbursement

## Implementation Details

### Invoice Model (`lib/models/invoice.dart`)

#### New Fields
```dart
final bool isTaxDeductible; // Flag for tax deduction eligibility
final bool isClaimable; // Flag for insurance/reimbursement claim eligibility
```

#### New Helper Methods
```dart
double get taxDeductibleAmount => isTaxDeductible ? total : 0.0;
double get claimableAmount => isClaimable ? total : 0.0;
bool get canBeClaimed => isClaimable && isPaid;
bool get canBeTaxDeducted => isTaxDeductible && isPaid;
```

### Invoice ViewModel (`lib/viewmodels/invoice_view_model.dart`)

#### New Filtered Lists
```dart
List<Invoice> get taxDeductibleInvoices => _invoices.where((inv) => inv.isTaxDeductible).toList();
List<Invoice> get claimableInvoices => _invoices.where((inv) => inv.isClaimable).toList();
List<Invoice> get paidTaxDeductibleInvoices => _invoices.where((inv) => inv.isTaxDeductible && inv.isPaid).toList();
List<Invoice> get paidClaimableInvoices => _invoices.where((inv) => inv.isClaimable && inv.isPaid).toList();
```

#### New Total Calculations
```dart
double get totalTaxDeductibleAmount => _invoices.fold(0.0, (sum, inv) => sum + inv.taxDeductibleAmount);
double get totalClaimableAmount => _invoices.fold(0.0, (sum, inv) => sum + inv.claimableAmount);
double get paidTaxDeductibleAmount => paidTaxDeductibleInvoices.fold(0.0, (sum, inv) => sum + inv.taxDeductibleAmount);
double get paidClaimableAmount => paidClaimableInvoices.fold(0.0, (sum, inv) => sum + inv.claimableAmount);
```

#### New Search Methods
```dart
List<Invoice> getInvoicesByTaxEligibility(bool isTaxDeductible);
List<Invoice> getInvoicesByClaimEligibility(bool isClaimable);
List<Invoice> getInvoicesReadyForClaims(); // Paid and claimable
List<Invoice> getInvoicesReadyForTaxDeduction(); // Paid and tax deductible
```

### UI Components

#### Invoice Card (`lib/views/invoices/widgets/invoice_card.dart`)
- Added small badges next to the status chip showing "Tax" and "Claim" indicators
- Green badge for tax deductible invoices
- Blue badge for claimable invoices

#### Invoice Detail Screen (`lib/views/invoices/invoice_detail_screen.dart`)
- Added a new "Tax & Claim Eligibility" section
- Shows eligibility status with icons and colored badges
- Displays tax deductible and claimable amounts
- Visual indicators for eligible vs non-eligible invoices

## Default Values

- **Medical Services**: Both flags default to `true` (tax deductible and claimable)
- **Prescriptions**: Both flags default to `true` (tax deductible and claimable)
- **Other Services**: Can be set to `false` for non-medical services (e.g., wellness spa services)

## Example Usage

### Creating an Invoice with Tax/Claim Flags
```dart
Invoice invoice = Invoice(
  // ... other required fields ...
  isTaxDeductible: true,  // Medical service - tax deductible
  isClaimable: true,      // Medical service - claimable
);
```

### Filtering Invoices
```dart
// Get all tax deductible invoices
List<Invoice> taxDeductible = viewModel.taxDeductibleInvoices;

// Get all claimable invoices
List<Invoice> claimable = viewModel.claimableInvoices;

// Get invoices ready for claims (paid and claimable)
List<Invoice> readyForClaims = viewModel.getInvoicesReadyForClaims();

// Get total tax deductible amount
double totalTaxDeductible = viewModel.totalTaxDeductibleAmount;
```

## Mock Data Examples

The system includes mock data with different combinations:

1. **Medical Service Invoice**: `isTaxDeductible: true`, `isClaimable: true`
2. **Prescription Invoice**: `isTaxDeductible: true`, `isClaimable: true`
3. **Wellness Service Invoice**: `isTaxDeductible: false`, `isClaimable: false`

## Future Enhancements

Potential future features that could be built on top of this foundation:

1. **Tax Reporting**: Generate tax deduction reports for financial year
2. **Insurance Claims**: Direct integration with insurance providers
3. **Claim Tracking**: Track the status of submitted insurance claims
4. **Tax Calculator**: Calculate potential tax savings based on deductible amounts
5. **Export Features**: Export eligible invoices for tax filing or insurance claims

## Benefits

1. **Clear Visibility**: Users can easily identify which invoices are eligible for tax deductions and insurance claims
2. **Financial Planning**: Users can track their total deductible and claimable amounts
3. **Compliance**: Helps users maintain proper records for tax and insurance purposes
4. **User Experience**: Visual indicators make it easy to understand invoice eligibility at a glance 