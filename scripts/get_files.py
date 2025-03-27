import argparse
import htmllistparse
import requests
import sys

from bs4 import BeautifulSoup
from collections import namedtuple

def compare_versions(v1, v2):
    """Compare two version strings in format a.b.c.d
    Returns 0 if they are the same, 
    -1 if v1 > v2
    1 if v2 > v1
    """

    if(v1 == v2):
        return 0
    v1t = [int(num) for num in v1.version.split('.')]
    v2t = [int(num) for num in v2.version.split('.')]

    for v1v, v2v in zip(v1t, v2t):
        if(v1v > v2v):
            return -1
        elif(v2v > v1v):
            return 1

    r1 = int(v1.release)
    r2 = int(v2.release)
    if r2 > r1:
        return 1
    elif r1 > r2:
        return -1

    return 0

def get_file(url, names, ext=None):

    response = requests.get(url)
    html = response.text

    soup = BeautifulSoup(html, "html.parser")
    cwd, listing = htmllistparse.parse(soup)

    targets = []
    for name in names:
        Package = namedtuple('Package', ['name', 'version', 'release', 'url'])

        target = None
        for entry in listing:
            parts = entry.name.split("-")
            entry_ext=parts[-1].split(".")[-1]

            if parts[0] == name and (ext != None and ext == entry_ext):
                package = Package(parts[0], parts[1], parts[2].split('.')[0], entry.name)
                if target is None:
                    target = package
                else:
                    if compare_versions(target, package) == 1:
                        target = package

        if target is not None:
            targets.append(target.url)

    return targets

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-u", "--url", help="URL of the repository")
    parser.add_argument("-n", "--names", help="The names of hte packages")
    parser.add_argument("-e", "--ext", help="The extension")

    args = parser.parse_args()
    names = args.names.split(",")

    targets = get_file(args.url, names, args.ext)
    if not targets:
        sys.stdout.write("")
    else:
        sys.stdout.write(" ".join(targets))
        
    return targets

if __name__ == '__main__':
    main()

# Assuming the server returns a directory listing in a table
##table = soup.find("table")
#for row in table.find_all("tr"):
#    cols = row.find_all("td")
#    if cols:
#        filename = cols.:inlineRefs{references="&#91;&#123;&quot;type&quot;&#58;&quot;inline_reference&quot;,&quot;start_index&quot;&#58;719,&quot;end_index&quot;&#58;722,&quot;number&quot;&#58;0,&quot;url&quot;&#58;&quot;https&#58;//stackoverflow.com/questions/11023530/python-to-list-http-files-and-directories&quot;,&quot;favicon&quot;&#58;&quot;https&#58;//imgs.search.brave.com/4WRMec_wn8Q9LO6DI43kkBvIL6wD5TYCXztC9C9kEI0/rs&#58;fit&#58;32&#58;32&#58;1&#58;0/g&#58;ce/aHR0cDovL2Zhdmlj/b25zLnNlYXJjaC5i/cmF2ZS5jb20vaWNv/bnMvNWU3Zjg0ZjA1/YjQ3ZTlkNjQ1ODA1/MjAwODhiNjhjYWU0/OTc4MjM4ZDJlMTBi/ODExYmNiNTkzMjdh/YjM3MGExMS9zdGFj/a292ZXJmbG93LmNv/bS8&quot;,&quot;snippet&quot;&#58;&quot;The&#32;htmllistparse&#32;python&#32;module&#32;retrieves&#32;HTML&#32;directory&#32;listings&#32;in&#32;a&#32;structured&#32;way&#58;\nFileEntry(name='english.au',&#32;modified=time.struct_time(tm_year=1994,&#32;tm_mon=3,&#32;tm_mday=18,&#32;tm_hour=0,&#32;tm_min=0,&#32;tm_sec=0,&#32;tm_wday=4,&#32;tm_yday=77,&#32;tm_isdst=-1),&#32;size=41984,&#32;description=None)\nFor&#32;cases&#32;where&#32;retrieving&#32;the&#32;listing&#32;is&#32;more&#32;complex,&#32;it's&#32;possible&#32;to&#32;do&#32;that&#32;separately&#32;and&#32;pass&#32;the&#32;result&#32;to&#32;htmllistp…&quot;&#125;&#93;"}text.strip()
#        print(filename)