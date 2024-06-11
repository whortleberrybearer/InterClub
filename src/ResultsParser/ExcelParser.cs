using OfficeOpenXml;
using System.Globalization;

internal static class ExcelParser
{
    internal static int? ParseNumber(ExcelRange cell)
    {
        if (!int.TryParse(cell.Text?.Trim(), out int number))
        {
            return null;
        }

        return number;
    }

    internal static string? ParseString(ExcelRange cell)
    {
        if (string.IsNullOrWhiteSpace(cell.Text))
        {
            return null;
        }

        return cell.Text.Trim();
    }

    internal static TimeSpan? ParseTime(ExcelRange cell)
    {
        if (string.IsNullOrWhiteSpace(cell.Text))
        {
            return null;
        }

        if (cell.Value is DateTime dateTime)
        {
            return dateTime.TimeOfDay;
        }

        // Times are often in the format 23:45, so check these time first.
        string[] formats = new string[] { @"hh\:mm\:ss", @"mm\:ss", @"mm\.ss", @"h\.mm\.ss" };

        if (TimeSpan.TryParseExact(cell.Text.Trim(), formats, DateTimeFormatInfo.CurrentInfo, out TimeSpan time))
        {
            return time;
        }

        // Failed to parse.  This may be because the result is displayed in minutes, not hours, so extract individually.
        string[] parts = cell.Text.Trim().Split(new char[] { ':', '.' });

        // 2 parts, so assume minutes and seconds.
        if ((parts.Length == 2) && int.TryParse(parts[0], out int minutes) && int.TryParse(parts[1], out int seconds))
        {
            return TimeSpan.FromMinutes(minutes).Add(TimeSpan.FromSeconds(seconds));
        }

        return null;
    }
}