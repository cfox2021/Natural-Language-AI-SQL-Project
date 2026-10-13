My project models fictional restaurant customers, their contact preferences, preferred payment methods, completed orders, and saved favorite orders. The database separates menu items from purchased order lines and saved favorite-order lines. Each purchased line stores the price at the time of the order, so later menu price changes do not change past totals.

A query that worked:

Question: What items are in Maya Chen's Friday Pizza Night favorite order?

Rows returned by both strategies: Margherita Pizza (1), Iced Tea (2).

A query that returned an incorrect result:

Question: Customers who prefer Google Pay or Apple Pay?

Generated result from both strategies: Maya Chen and Sam Brooks.

Problem: Both queries matched wallet providers but omitted payment_method.is_preferred = 1. Maya has Apple Pay saved as a payment option, but her preferred method is Visa.

The corrected result is Sam Brooks.

Prompting strategies:

I compared zero-shot and single-domain double-shot prompting using the same data and eight questions. All 16 queries ran, but some results were incorrect. Both strategies counted a cancelled order in sales totals and included Maya for my Google Pay / Apple Pay question, even though only Sam prefers one of those methods. Zero-shot correctly counted preferred payment types; double-shot did not. Both spending queries omitted Riley, who spent $0.
The strategies answered the other questions correctly. These results show that SQL can run successfully and still misunderstand a question. See examples.md for details.
