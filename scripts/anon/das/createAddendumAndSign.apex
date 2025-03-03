VCC_DasCreateAddendumAndSignRQ createAddendumAndSignRq = new VCC_DasCreateAddendumAndSignRQ();
createAddendumAndSignRq.supplementalParameters = new List<String>{};
createAddendumAndSignRq.providerUserId = ''; // token
createAddendumAndSignRq.providerName = '';
createAddendumAndSignRq.providerLoginSiteCode = '984';
createAddendumAndSignRq.esig = 'TESTER';
createAddendumAndSignRq.type = '81';
createAddendumAndSignRq.itemId = '5309360';
createAddendumAndSignRq.criteria = 'Addendum: 12345|';
(new VCC_DAS()).createAddendumAndSign(createAddendumAndSignRq, 'a1Z3S000000rTedUAE');
