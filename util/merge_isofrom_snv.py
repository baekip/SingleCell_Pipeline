#!/usr/bin/python

import openpyxl as px
import sys
import os
import argparse

def xlsx_read(input_file, output_file):

    output_fp = open(output_file, 'w')

    dic_head = {}
    dic_data = {}
    set_data = set()
    list_data = []
    with open(input_file) as input_fp:
        for line in input_fp:
            units = line.strip().split('\t')
            if line.startswith('#CHROM'):
                head = units
                for idx in range(len(head)):
                    col_name = head[idx]
                    dic_head[str(idx)] = col_name
                    dic_head[col_name] = idx
                print >> output_fp, '\t'.join(head)
            else:
                chr_id_idx = dic_head['#CHROM']
                bp_idx = dic_head['POS']
                ref_idx = dic_head['REF']
                alt_idx = dic_head['ALT']
                gene_idx = dic_head['ANN[*].GENE']

                chr_id = units[chr_id_idx]
                bp_id = units[bp_idx]
                ref_id = units[ref_idx]
                alt_id = units[alt_idx]
                gene_id = units[gene_idx]

                key_idx = '%s:%s:%s:%s:%s' %(chr_id, bp_id, ref_id, alt_id, gene_id)
                if key_idx in set_data:
                    dic_data[key_idx].append(units)
                else:
                    dic_data[key_idx] = []
                    dic_data[key_idx].append(units)

                    set_data.add(key_idx)
                    list_data.append(key_idx)

    for key_idx in list_data:
        row_data = dic_data[key_idx]
        if len(row_data) == 1:
#            print row_data
            print >> output_fp, '\t'.join(row_data[0])
        else:
            dic_row = {}
            effect_idx = dic_head['ANN[*].EFFECT']
            distance_idx = dic_head['ANN[*].DISTANCE']
            for idx in range(effect_idx, distance_idx + 1):
                col_name = head[idx]
                dic_row[col_name] = []

            for item in row_data:
                for idx in range(effect_idx, distance_idx + 1):
                    col_name = head[idx]
                    dic_row[col_name].append(item[idx])

            list_output = []
            for idx in range(0, effect_idx):
                list_output.append(row_data[0][idx])
            for idx in range(effect_idx, distance_idx + 1):
                col_name = head[idx]
                if col_name == 'ANN[*].GENE':
                    list_output.append(dic_row[col_name][0])
                else:
                    list_output.append(','.join(dic_row[col_name]))
            for idx in range(distance_idx + 1, len(head)):
                list_output.append(row_data[0][idx])

            print >> output_fp, '\t'.join(list_output)

    output_fp.close()
    return

def usage():
    message='''
python %s

-i, --input      : snpeff tsv file

##optional
-o, --output : default(output.tsv)
''' %sys.argv[0]
    print message


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', '--input')
    parser.add_argument('-o', '--output', default="output.xlsx")
    parser.add_argument('-v', dest='verbose', action='store_true')
    args = parser.parse_args()
    try:
        len(args.input) > 0

    except:
        usage()
        sys.exit(2)

    xlsx_read(args.input, args.output)

if __name__ == '__main__':
    main()
