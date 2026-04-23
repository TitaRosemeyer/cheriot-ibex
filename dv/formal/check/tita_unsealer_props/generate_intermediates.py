import re as regex
import os
path = os.path.dirname(os.path.abspath(__file__)) + "/"

def close_brackets(text:str, open_bracket: str = "(", close_bracket: str = ")") -> str:
    """
    Close brackets in the text by adding a closing bracket at the end if it is missing.
    This is useful for ensuring that properties are well-formed.
    """
    open_count = text.count(open_bracket)
    close_count = text.count(close_bracket)

    if open_count > close_count:
        return text + close_bracket * (open_count - close_count)
    return text

def iter_lines(text: str, dividers: list[str] = ["\n"], match_last_line: str = r"`INSTR_WB\((\w+)\)", yield_last: bool = True):
    """
    Iterate over lines in the text, splitting by the given dividers.
    Yields tuples of (index, lines_until_now, last_line).
    - index: the index of the current divider
    - lines_until_now: the text up to the current divider
    - last_line: the last line added since the last divider
    If match_last_line is provided, it will be used to extract a specific part of the last line.
    """
    divider = "|".join(map(regex.escape, dividers))
    matches = regex.finditer(divider, text)

    last_end = 0 
    for i, match in enumerate(matches):
        last_line = text[last_end:match.start()].strip()
        last_end = match.end()

        lines_until_now = text[:match.start()].rstrip()

        if match_last_line:
            var_match = regex.search(match_last_line, last_line)
            if var_match:
                last_line = var_match.group(1)
            else:
                last_line = "na"

        if last_line:
            yield i, lines_until_now, last_line

    if yield_last:
        last_line = text[last_end:].strip()
        if match_last_line:
            var_match = regex.search(match_last_line, last_line)
            if var_match:
                last_line = var_match.group(1)
            else:
                last_line = "na"
        yield i + 1, text.rstrip(), last_line

def write_intermediates(file_path: str, generator, combined_prop_name: str = None) -> None:
    prop_names = []
    with open(file_path, "w") as f:
        for p in generator:
            if isinstance(p, tuple):
                prop_name, p = p
                prop_names.append(prop_name+"_prop")
            f.write(p)
            f.write("\n")
        if combined_prop_name and prop_names:
            f.write(f"property {combined_prop_name}_prop;\n")
            f.write("\t(" + " and ".join(prop_names) + ");\n")
            f.write("endproperty;\n")
            f.write(f"{combined_prop_name}: assert property ({combined_prop_name}_prop);\n")



def make_property(name: str, antecedent: str, consequent: str) -> str:
    antecedent = close_brackets(antecedent)
    return f"""
property {name}_prop; 
\t({antecedent} 
\t|-> {consequent});
endproperty; 
{name}: assert property ({name}_prop);
    """      

def make_sequence(name: str, sequence: str, check_cover: bool) -> str:
    sequence = close_brackets(sequence)
    cover = f"\ncover_{name}: cover sequence ({name});" if check_cover else ""
    return f"""
sequence {name};
\t({sequence});
endsequence;{cover}
"""

def parse_property_body(property_text: str) -> tuple[str, str]:
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

    return antecedent, consequent

def parse_property_text(text: str) -> tuple[str, str, str]:
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

    antecedent, consequent = parse_property_body(property_text)

    # print(f"property name: {name}")
    # print(f"antecedent: {antecedent}")
    # print(f"consequent: {consequent}")

    return name, antecedent, consequent

def generate_intermediate_props(property_text: str, dividers: list[str] = ["\n"], yield_prop_names: bool = False, yield_last: bool = False):
    # parse the property text to get the name, antecedent, and consequent
    name, antecedent, consequent = parse_property_text(property_text)

    # split the antecedent into lines based on the dividers
    # and yield a property for each line
    lines = iter_lines(antecedent, dividers=dividers, yield_last=yield_last)
    for i, curr_antecedent, last_line in lines:
        if curr_antecedent:  # only yield non-empty 
            prop_name = f"{name}_{i+1}_{last_line}"
            prop = make_property(prop_name, curr_antecedent, consequent)
            if yield_prop_names:
                yield prop_name, prop
            else:
                yield prop

def generate_branches(main_sequence: str, branch_signal: str = "wbexc_has_branched", branch_sequence: str = "failure_sequence", include_success: bool = False, check_cover: bool = True):
    """
    Generate a sequence that includes the main sequence and branches based on the branch signal.
    """
    lines = iter_lines(main_sequence, dividers=[f"&& instr_will_progress && ~{branch_signal}"], yield_last=False)
    for i, curr_sequence, last_line in lines:
        if curr_sequence:
            # Take the branch at the end of the current sequence
            curr_sequence += f" && {branch_signal} \n\t##1 ~wbexc_exists \n\t##1 {branch_sequence}"
            yield make_sequence(f"branch_{i+1}_{last_line}", curr_sequence, check_cover=check_cover)
    if include_success:
        yield make_sequence(f"branch_{i+2}_success", main_sequence, check_cover=check_cover)

property_str = """
property no_wbexc_err_prop;
    (assumption and (`INSTR_WB(l00_cgettag) && instr_will_progress 
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
        ##1 `INSTR_WB(l28_clw) && ~instr_will_progress 
        ##1 instr_will_progress
        ##1 `INSTR_WB(l2a_bne) && instr_will_progress && ~wbexc_has_branched
        ##1 `INSTR_WB(l2e_cgettop) && instr_will_progress
        ##1 `INSTR_WB(l32_cinoffset) && instr_will_progress
        ##1 `INSTR_WB(l36_sub) && instr_will_progress
        ##1 `INSTR_WB(l3a_csetboundsexact) && instr_will_progress
        ##1 `INSTR_WB(l3e_cret))
        |-> (~wbexc_err | (obj_ptr_safe && us_auth_safe))
        );
endproperty
no_wbexc_err: assert property (no_wbexc_err_prop);
"""


def write_branches() -> None:
    sequence = parse_property_text(property_str)[1]
    file_name = "branches.sv"
    branches = generate_branches(sequence, include_success=True, check_cover=True)
    write_intermediates(path + file_name, branches)

def write_no_wbexc_err_intermediates() -> None:
    file_name = "wbexc_err_props.sv"
    intermediates = generate_intermediate_props(property_str, dividers=["&& instr_will_progress", "##1 instr_will_progress"], yield_prop_names=True)
    write_intermediates(path + file_name, intermediates, combined_prop_name="no_wbexc_err")

if __name__ == "__main__":
    write_branches()
    write_no_wbexc_err_intermediates()