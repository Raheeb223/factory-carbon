# Sample bills

Put **redacted** bill images here (PNG, JPEG or PDF). Before adding a file, black out
customer name, address, consumer/account number, meter number and phone numbers.

Each image `<stem>.<ext>` needs a matching `../ground_truth/<stem>.json`.
Expected first file: `bpdb_may24.jpg` (or `.png`/`.pdf`), ground truth already present.

Run the evaluation from `backend/`:

```
python -m scripts.eval_extraction
```
