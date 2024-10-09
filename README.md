# Understanding LLVM Intermediate Representation
This is the documentation narrating my process when tinkering and learning LLVM Intermediate Representation. The purpose to this investigation is to gain a better undesrstanding to C programs and the languages architecture. I understand that reading the documentation may be more effective method to learning, but condider the following...
    1. That is boring as hell.
    2. I have more control over what I learn. I can focus on concepts that previously confused me, like memory management.
    3. I can use the documentation to aid my experimenting.

What is the end goal of this? Well as I said to better understand the relationship between C source code and the generated instruction set. But the second purpose is to create a mini game (and by 'mini' I mean bloody tiny)... The game in question? A number guessing game! Then afterwards I can create the code in C and convert to IR and compare to my manually created IR. So lets get into it.
