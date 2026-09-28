import urllib.request
import urllib.error
import ssl
import sys

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

urls = [
    ("Page 33 - StepAcademic RUI", "https://stepacademic.net/ijcsr/article/view/441/195"),
    ("Page 35 - IET Barua & Kaiser", "https://ietresearch.onlinelibrary.wiley.com/doi/10.1049/tje2.70139"),
    ("Page 42 - MDPI Skurowski", "https://www.mdpi.com/1424-8220/22/19/7230"),
    ("Page 44 - IJNRD Desale", "https://ijnrd.org/papers/IJNRD2505207.pdf"),
    ("Page 50 - SemanticScholar Parmon", "https://pdfs.semanticscholar.org/549a/4018d1402611a1992b0578eac2c9d08dba53.pdf"),
    ("Ref - SSRN Afable", "https://ssrn.com/abstract=4871527"),
    ("Ref - IJIST Ahmed", "https://www.ijisnt.com/journal/index.php/public_html/article/view/22"),
    ("Ref - IEEE Ahmed TITS", "https://doi.org/10.1109/tits.2023.3323097"),
    ("Ref - MDPI Alsuhibany", "https://doi.org/10.3390/s25133855"),
    ("Ref - ResearchGate Barde", "https://www.researchgate.net/publication/362137280_A_Review_of_Parking_Management_System_at_SSCET_Campus"),
    ("Ref - ACM Bastani", "https://doi.org/10.1145/3474717.3483651"),
    ("Ref - ACM Bekavac", "https://doi.org/10.1145/3613905.3651006"),
    ("Ref - ResearchGate Chan", "https://www.researchgate.net/publication/400860353_Strategic_Evaluation_of_GCash_-_Internal_External_Analysis_on_the_E-Wallet_Industry_in_the_Philippines_to_Formulate_feasibility_of_introducing_New_Revenue_Streams_to_support_upcoming_IPO"),
    ("Ref - ResearchGate Fabro", "https://www.researchgate.net/publication/397254755_A_Comparative_Analysis_of_GCash_and_PayPal_E-Wallets_in_Online_Shopping_Platforms"),
    ("Ref - Theseus Gamage", "https://www.theseus.fi/bitstream/handle/10024/341123/Neupane_Ganesh.pdf?sequence=2&isAllowed=y"),
    ("Ref - DOI Grepon", "https://doi.org/10.25147/ijcsr.2017.001.1.158"),
    ("Ref - MDPI Kim", "https://doi.org/10.3390/rs15153791"),
    ("Ref - ProQuest Larraquel", "https://www.proquest.com/openview/6b3fd811cfc0b2ce480f557b84219fe7/1?pq-origsite=gscholar&cbl=18750&diss=y"),
    ("Ref - Elsevier Pouri", "https://doi.org/10.1016/j.eist.2020.12.003"),
    ("Ref - MDPI Raza", "https://doi.org/10.3390/encyclopedia2030083"),
    ("Ref - Elsevier Sartayeva", "https://doi.org/10.1016/j.comnet.2023.110042"),
    ("Ref - Elsevier Vovveti", "https://doi.org/10.1016/j.jclepro.2020.122877"),
    ("Ref - IET Guzman", "https://doi.org/10.1049/icp.2025.0529"),
    ("Ref - UTAR Xin", "http://eprints.utar.edu.my/7109/1/fyp_CS_2025_KWX.pdf")
]

results = []
print("Testing URLs...")
for name, url in urls:
    req = urllib.request.Request(
        url, 
        headers={'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'}
    )
    try:
        with urllib.request.urlopen(req, timeout=10, context=ctx) as resp:
            code = resp.getcode()
            ctype = resp.headers.get('Content-Type', '').split(';')[0].strip()
            final_url = resp.geturl()
            print(f"[SUCCESS {code}] {name} | Type: {ctype} | Final: {final_url}")
            results.append((name, url, "OK", code, ctype, final_url))
    except urllib.error.HTTPError as e:
        print(f"[HTTP ERROR {e.code}] {name} | URL: {url} | Reason: {e.reason}")
        results.append((name, url, f"HTTP Error {e.code}", e.code, "", ""))
    except Exception as e:
        print(f"[FAILED] {name} | URL: {url} | Error: {e}")
        results.append((name, url, f"Error: {e}", 0, "", ""))

print("\n--- Summary Finished ---")
