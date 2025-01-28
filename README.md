# enumeration

enumeration script for automation a basic enumerations including
    Sublist3r: Finds subdomains.
    Curl: Checks if subdomains are live by sending an HTTP request.
    Dnsenum: Enumerates DNS records.
    Nmap: Scans open ports and services.
    Gobuster: Fuzzes directories on live subdomains using a wordlist.
    
    The script saves all results in the enum_results directory, including:
        subdomains.txt: List of found subdomains.
        live_subdomains.txt: List of live subdomains.
        dns_records.xml: DNS records.
        nmap_scan.*: Nmap scan results.
        gobuster_*.txt: Directory fuzzing results for each live subdomain.
