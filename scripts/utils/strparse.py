from pathlib import Path
from datetime import datetime
from utils.xlogging import get_logger

logger = get_logger()

def find_most_recent_match(dir_path:Path, query:str) -> Path | None:
    """ Find the most recent file matching a timestamp query in a directory.

    :param dir_path: (Path) Path to the directory with timestamped files
    :param query: (str) Query string of letters from 'ymdhms' and digits for those fields
    :return: (Path | None) Most recent matching file or None if no match
    """
    dir_path = Path(dir_path)
    files = [p for p in dir_path.iterdir() if p.is_file()]
    if not files:
        return None

    # If query is empty, return the most recent file by timestamp
    if not query:
        parsed = []
        for p in files:
            name = p.name
            ts_part = name.split('_', 1)[0]
            ts_str = ts_part.replace('-', '')
            try:
                dt = datetime.strptime(ts_str, '%y%m%d%H%M%S')
            except (ValueError, TypeError):
                continue
            parsed.append((p, dt))
        if not parsed:
            return None
        return [item[0] for item in sorted(parsed, key=lambda x: x[1], reverse=True)[:2]]

    # Parse query into letters and digits
    letters = ''.join(c for c in query if c.isalpha())
    digits = ''.join(c for c in query if c.isdigit())
    fields = ['y', 'm', 'd', 'h', 'm', 's']

    # Map each letter to its timestamp field index
    indices = []
    prev = -1
    for letter in letters:
        for i in range(prev + 1, len(fields)):
            if fields[i] == letter:
                indices.append(i)
                prev = i
                break
        else:
            raise ValueError(f"Invalid query letter: {letter}")

    # Ensure digit count matches requested fields (2 digits per field)
    if len(digits) != len(indices) * 2:
        raise ValueError("Digit count does not match query fields")
    groups = [digits[i*2:(i+1)*2] for i in range(len(indices))]

    # Find matching files
    matches = []
    for p in files:
        name = p.name
        ts_part = name.split('_', 1)[0]
        ts_str = ts_part.replace('-', '')
        if len(ts_str) < 12:
            continue
        # Check each requested segment
        for idx, grp in zip(indices, groups):
            start = idx * 2
            if ts_str[start:start+2] != grp:
                break
        else:
            try:
                dt = datetime.strptime(ts_str, '%y%m%d%H%M%S')
            except ValueError:
                continue
            matches.append((p, dt))

    if not matches:
        return None
    return [match[0] for match in sorted(matches, key=lambda x: x[1], reverse=True)[:2]]
