export const buildCategory = (sex, ageCategory) => {
    const sexValue = sex === 1 ? "M" : "F";

    if (ageCategory === 2) {
        return sexValue;
    }
    else if (ageCategory === 1) {
        return "J" + sexValue;
    }
    else {
        return sexValue + "V" + (((ageCategory - 3) * 5) + 35);
    }
}