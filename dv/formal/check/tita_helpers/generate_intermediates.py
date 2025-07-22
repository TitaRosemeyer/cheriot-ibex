def make_property(name: str, antecedent: str, consequent: str) -> str:
    return f"""
property {name}_prop; 
\t({antecedent} 
\t|-> {consequent});
endproperty; 
{name}: assert property ({name}_prop);
    """
import re as regex          
def property_text_to_lines(text: str, dividers: list[str] = ["\n"]):
    # first, find "property [name];" in the text
    # and put name in a variable
    match = regex.search(r"property\s+(\w+);", text)
    if not match:
        raise ValueError("No property found in the text")
    name = match.group(1)

    # remove _prop from name if it exists
    if name.endswith("_prop"):
        name = name[:-5]

    # then take everything after that
    text = text[match.end():]
    
    # now find everything before the first 'endproperty'
    end_match = regex.search(r"endproperty", text)
    if not end_match:
        raise ValueError("No endproperty found in the text")
    property_text = text[:end_match.start()].strip()

    # Now, strip the first '(' on the left and the last ');' on the right
    # but if i have '((' at the start, remove only one '('
    if property_text.startswith("(("):
        property_text = property_text[1:]
    else:
        property_text = property_text.lstrip("(").strip()
    
    if property_text.endswith("));"):
        property_text = property_text[:-2].strip()
    else:
        property_text = property_text.rstrip(");").strip()
    
    # Now split the text into antecedent and consequent
    # The antecedent is everything before the first '|->'
    antecedent, consequent = property_text.split("|->", 1)
    consequent = consequent.strip()
    print(f"antecedent: {antecedent}")
    print(f"consequent: {consequent}")

    # Now split the antecedent into lines at any of the dividers
    divider = "|".join(map(regex.escape, dividers))
    # now, find all the matches of the antecedent for the dividers, but do not split
    matches = regex.finditer(divider, antecedent)
    # for each match, yield the antecedent up to that match
    last_end = 0
    for i, match in enumerate(matches):
        # get last line added
        last_line = antecedent[last_end:match.start()].strip()
        # find `INSTR_WB({var})` in the last line and find var
        var_match = regex.search(r"`INSTR_WB\((\w+)\)", last_line)
        if var_match:
            last_line = var_match.group(1)
        else:
            last_line = "na"

        last_end = match.end()
        curr_antecedent = antecedent[:match.start()].rstrip()
        if curr_antecedent:  # only yield non-empty antecedents
            yield make_property(f"{name}_{i+1}_{last_line}", curr_antecedent, consequent)




def property_to_intermediates(text: str, file_path: str, dividers: list[str] = ["\n"]) -> None:
    with open(file_path, "w") as f:
        for p in property_text_to_lines(text, dividers):
            f.write(p)
            f.write("\n")

property_str = """
property no_wbexc_err_prop;
    (`INSTR_WB(l00_cgettag) && instr_will_progress 
        ##1 `INSTR_WB(l04_beqz) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l06_cgetbase) && instr_will_progress 
        ##1 `INSTR_WB(l0a_bne) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l0e_cgetlen) && instr_will_progress 
        ##1 `INSTR_WB(l12_beqz) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l14_cgetperm) && instr_will_progress 
        ##1 `INSTR_WB(l18_andi) && instr_will_progress 
        ##1 `INSTR_WB(l1c_bne) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l1e_cunseal) && instr_will_progress 
        ##1 `INSTR_WB(l22_cgettag) && instr_will_progress 
        ##1 `INSTR_WB(l26_beqz) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l28_clw) && ~instr_will_progress // load stalls for one cycle
        ##1 instr_will_progress
        ##1 `INSTR_WB(l2a_bne) && instr_will_progress && ~wbexc_has_branched
        ##1 `INSTR_WB(l2e_cgettop) && instr_will_progress
        ##1 `INSTR_WB(l32_cinoffset) && instr_will_progress
        ##1 `INSTR_WB(l36_sub) && instr_will_progress
        ##1 `INSTR_WB(l3a_csetboundsexact) && instr_will_progress
        |-> ~wbexc_err
        );
endproperty
no_wbexc_err: assert property (no_wbexc_err_prop);
"""

file_name = "help_no_wbexc_err.sv"
path = "/home/mf24tpr/cheriot-ibex/dv/formal/check/tita_helpers/"

property_to_intermediates(property_str, path + file_name, dividers=["&& instr_will_progress", "##1 instr_will_progress"])