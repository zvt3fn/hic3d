import sys,argparse

def make_table(filename):
    new_name = filename.split(".")[0]
    f = open(new_name+".html", "w")
    # begin the table
    f.write("<!DOCTYPE html><html><head><script src=\"https://www.kryogenix.org/code/browser/sorttable/sorttable.js\"></script><style>#factors {font-family: Arial, Helvetica, sans-serif;border-collapse: collapse;width: 100%;} #factors td, #factors th { border: 1px solid #ddd; padding: 8px;} #factors tr:nth-child(even){background-color: #f2f2f2;} #factors tr:hover {background-color: #ddd;} #factors th { padding-top: 12px;padding-bottom: 12px; text-align: left; background-color: #4CAF50; color: white;}</style></head>")
    f.write("<body>")
    f.write("<table id=\"factors\" class=\"sortable\">")

    # column headers
    f.write("<tr>")
    f.write("<th>TR</th>")
    f.write("<th>STATISTIC</th>")
    f.write("<th>PVALUE</th>")
    f.write("<th>ZSCORE</th>")
    f.write("<th>MAX_AUC</th>")
    f.write("<th>RE_RANK</th>")
    f.write("<th>IRWIN_HALL_PVALUE</th>")
    f.write("</tr>")

    infile = open(filename,"r")

    i = 0
    for line in infile:
        if i != 0:
            row = line.split("\t")
            tr = row[0]
            stat = row [1]
            pv = row[2]
            zs = row[3]
            ma = row[4]
            rr = row[5]
            ihpv = row[6]
                        
            num = float(ihpv)
            
            if num < 0.01:
                f.write("<tr style=\"background-color:#95aef0;\">")
            else:
                f.write("<tr>")
            f.write("<td>%s</td>" % tr)
            f.write("<td>%s</td>" % stat)
            f.write("<td>%s</td>" % pv)
            f.write("<td>%s</td>" % zs)
            f.write("<td>%s</td>" % ma)
            f.write("<td>%s</td>" % rr)
            if num < 0.01:
                f.write("<td><b>%f</b></td>" % num)
            else:
                f.write("<td>%f</td>" % num)
            f.write("</tr>")
        i += 1
    # end the table
    f.write("</table>")
    f.write("</body>")
    f.write("</html>")
    f.close()

if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument('-i', '--indir', action = 'store', type = str,dest = 'indir', help = 'input dir of ', metavar = '<dir>')    

    args = parser.parse_args()
    if(len(sys.argv))<0:
        parser.print_help()
        sys.exit(1)
    make_table(args.indir)
