/**
 * @author Patrick Skamarak
 * @since 02/01/2023
 *
 * URN - Uniform Resource Name Syntax (RFC 8141)
 * @see UrnTest.cls, VCC_UrnService, VCC_UrnServiceTest for more info
 */
public class URN {
    public String urnPrefix = '';

    public String namespaceId = '';

    public String namespaceSpecificSection = '';

    public String rComponent = '';

    public String qComponent = '';

    public String fComponent = '';

    public String toFullString() {
        return String.join(
            new List<String>{
                urnPrefix,
                namespaceId,
                namespaceSpecificSection +
                (String.isBlank(rComponent) ? '' : '?+') +
                rComponent +
                (String.isBlank(qComponent) ? '' : '?=') +
                qComponent +
                (String.isBlank(fComponent) ? '' : '#') +
                fComponent
            },
            ':'
        );
    }

    public override String toString() {
        return String.join(new List<String>{ urnPrefix, namespaceId, namespaceSpecificSection }, ':');
    }

    public Boolean fullEquals(Object obj) {
        if (obj == null) {
            return false;
        }
        if (!(obj instanceof Urn)) {
            return false;
        }

        Urn urn = (Urn) obj;
        if (urn.urnPrefix != this.urnPrefix) {
            return false;
        }
        if (urn.namespaceId != this.namespaceId) {
            return false;
        }
        if (urn.namespaceSpecificSection != this.namespaceSpecificSection) {
            return false;
        }
        if (urn.rComponent != this.rComponent) {
            return false;
        }
        if (urn.qComponent != this.qComponent) {
            return false;
        }
        if (urn.fComponent != this.fComponent) {
            return false;
        }

        return true;
    }

    public Boolean equals(Object obj) {
        if (obj == null) {
            return false;
        }
        if (!(obj instanceof Urn)) {
            return false;
        }

        Urn urn = (Urn) obj;
        if (urn.urnPrefix != this.urnPrefix) {
            return false;
        }
        if (urn.namespaceId != this.namespaceId) {
            return false;
        }
        if (urn.namespaceSpecificSection != this.namespaceSpecificSection) {
            return false;
        }

        return true;
    }

    public Integer hashCode() {
        return this.toString().hashCode();
    }
}
