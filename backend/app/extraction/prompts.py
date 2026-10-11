"""Version-controlled extraction prompt (spec 6.1). Bump PROMPT_VERSION on any change."""

PROMPT_VERSION = "2026-10-11.1"

EXTRACTION_PROMPT = """\
You read one photographed or scanned utility bill from Bangladesh (electricity, gas
or diesel/fuel receipt) and return its data as JSON matching the given schema.

Rules, in priority order:
1. Read ONLY the top section of the page (the customer's copy). Bills often repeat
   the data in lower office/bank copies. Ignore those copies. If a lower copy shows
   different values, do not use them; say so in `notes`.
2. For consumed units use the printed "consumed units" / "units consumed" / "total
   units" value exactly as printed. NEVER compute it from present minus previous meter
   readings: a multiplying factor may apply, so the difference can be wrong.
3. Convert Bangla digits (০১২৩৪৫৬৭৮৯) to Western digits (0123456789). Remove
   thousands separators. Numbers must be plain JSON numbers.
4. Dates on these bills are written day/month/year. Output `period_start` and
   `period_end` as ISO dates (YYYY-MM-DD) and `billing_month` as YYYY-MM.
   Two-digit years mean 20YY: "Aug-26" is 2026-08 and "24/07/26" is 2026-07-24.
   Take the year only from what is printed. Never replace it with the current year or
   a year you think is more likely, even if it looks recent or in the future.
5. If a value is missing, cut off, blurred, ambiguous or you are not sure, return
   null for it. NEVER guess or infer a value that is not clearly printed.
6. NEVER output personal data: no customer names, addresses, phone numbers, meter
   numbers, consumer/account numbers or bank details, in any field including `notes`.

Field guidance:
- bill_type: "electricity", "gas", "diesel" or "unknown".
- utility_name: the utility or company that issued the bill (e.g. a distribution
  company name), not the customer.
- total_amount_bdt: the current month's payable amount in Bangladeshi Taka (BDT),
  not arrears and not the late-payment amount. If the bill prints both a bill-month
  total and a rounded net payable, use the net payable and mention the other in notes.
- unit: "kWh" for electricity, "m3" for gas, "litre" for diesel, or null if unclear.
- tariff_code: the tariff category printed on the bill (e.g. "LT-A", "LT-B").
- sanctioned_load_kw: sanctioned/contracted load in kW if printed.
- field_confidence: for every field you return a non-null value, give "high",
  "medium" or "low" confidence that it is exactly what is printed.
- notes: short, factual remarks (e.g. disagreeing copies, a multiplying factor,
  partly unreadable areas). No personal data.
"""
